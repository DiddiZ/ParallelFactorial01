import std.bigint;
import std.conv;
import std.stdio;
import std.parallelism;
import std.array;
import std.math;
import std.concurrency;

int main(string[] args) {

    	if(args.length != 2) {
		writeln("Please provide a number for which the factorial should be calculated.");
		return 1;
	}

    	// Read n:
	auto n = to!uint(args[1]);
    
    	// Catch the special cases:
    	if(n == 0) {
		writefln("%d!=1", n);
		return 0;
	}

	if(n == 1) {
		writefln("%d!=1", n);
		return 0;
	}

	if(n == 2) {
		writefln("%d!=2", n);
		return 0;
	}

    	// Set the number of CPUs for processing:
    	auto countCPUs = totalCPUs * 2; // 2x because of hyper-threadding of modern Intel CPUs. totalCPUs returns only the physical number of cores. 
    	writefln("The calculation will run on %d CPUs.", countCPUs);
    	defaultPoolThreads(countCPUs);

	//
    	// Create partitions. Each partition should multiply partitionSize numbers.
    	//

    	// It is an important key of success, to choose the right work load. Each thread must have a notable workload.
    	// Consider also, if all calculations should be done parallel, it makes no sense to create more partitions as
    	// count of CPUs. Therefore, we determine the size dynamically in order to define the size as big as necessary
    	// to create as many partitions as CPUs:
    	auto partitionSize = to!size_t(ceil(to!float(n) / to!float(totalCPUs * 2)));

    	// Create the partitions (first dimension, means partitions):
    	ulong[][] partitions; partitions.length = to!uint(ceil(to!float(n) / to!float(partitionSize)));
	writefln("Created %d partitions each of size %d.", partitions.length, partitionSize);
    	writeln("Start partitioning the numbers.");

    	// Index for the second dimension 0 - partitionSize i.e. the workload:
    	size_t numberIndex = 0;

    	// Loop over all numbes:
	foreach(number; 1 .. n+1) {

		// Determine which partition i.e. index for the first dimension:
		auto partitionIndex = to!uint(ceil(to!float(number) / to!float(partitionSize))) - 1;
		
		// Determine if a new partition starts:
		if(number % partitionSize == 1) {
	    		// A new partition: Allocate memory for partitionSize entries.
	    		partitions[partitionIndex].length = partitionSize;
		}
		
		// Store the numbers into the partition:
		//writefln("Debug: %d into part. %d, index %d", number, partitionIndex, numberIndex); // Debugging
		partitions[partitionIndex][numberIndex] = number;

		// Determine the next index for the second dimension:
		numberIndex = number % partitionSize;
	}

    	writeln("Done partitioning the numbers.");

    	// Define a concurrent receiver for interim values in order to calculate the final result also concurrent to the main threads:
    	auto receiverInterimTid = spawn(function void(Tid owner, size_t countInterimValues) {
		
		// Here, we store the main result:
		auto mainResult = BigInt("1");

		// We know how many interim values we receive. Thus, use a for-loop instead of waiting
		// for an cancelation signal from the main thread:
	    	for(auto n = countInterimValues; n > 0; n--) {
			// Receive an interim value. This call waits as long until a value gets available:
	    		auto received = receiveOnly!BigInt();
			
	    		// Update the result:
	    		mainResult *= received;
		}

	    	// If all interim values are collected and processed, send the result to the main thread:
		owner.send(mainResult);
    	}, thisTid(), partitions.length); // The receiver needs the main thread as well as the count of partitions
    	
    	// Define the handling of this receiver. The cache is 10000 items big.
    	// If the cache gets full, the calculating threads must wait.
    	setMaxMailboxSize(receiverInterimTid, 10000, OnCrowding.block);
    
    	writeln("Start calculating.");

    	// Run parallel all partitions:
    	foreach(partition; parallel(partitions)) {
		
		// This is the thread-local interim result:
		auto bigResult = BigInt("1");

		// Iterative multiplication of all number of this partition:
		foreach(number; partition) {
	    		
	    		// The last partition contains perhaps zeros.
	    		// Obvious, we should not multiply with zero:
	    		if(number > 0) {
		    		bigResult *= number;
		    	}
		}

		// If this partition was completely processed,
		// send the interim value to the receiver:
		receiverInterimTid.send(bigResult);
	}

    	writeln("All threads are started.");

	// Wait for the receiver:
    	auto mainResult = receiveOnly!BigInt();

    	writeln("Done calculating.");
    	writeln("Prepare formatting and printing.");
    	writefln("%d!=%s", n, mainResult.toDecimalString());
    	return 0;
}
