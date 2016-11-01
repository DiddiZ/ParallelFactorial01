import std.bigint;
import std.conv;
import std.stdio;
import std.parallelism;
import std.array;
import std.math;
import std.concurrency;

int main(string[] args) {

    	if(args.length != 2) {
		writeln("Please provide the n which factorial you want to know.");
		return 1;
	}

    	// Read n:
	auto n = to!uint(args[1]);
    
    	// A small n?
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

    	// Calculate all partitions parallel:
    	auto countCPUs = totalCPUs * 2;
    	writefln("Set number of CPUs for calculating to %d.", countCPUs);
    	defaultPoolThreads(countCPUs);

	//
    	// Create partitions. Each partition should multiply partitionSize numbers.
    	//
    	auto partitionSize = to!size_t(ceil(to!float(n) / to!float(totalCPUs * 2)));
    	ulong[][] partitions; partitions.length = to!uint(ceil(to!float(n) / to!float(partitionSize)));
	writefln("Created %d partitions each of size %d.", partitions.length, partitionSize);
    	writeln("Start partitioning the numbers.");

    	// Index for the second dimension 0-5:
    	size_t numberIndex = 0;

    	// Loop over all numbes:
	foreach(number; 1 .. n+1) {

		// Determine which partition i.e. index for the first dimension:
		auto partitionIndex = to!uint(ceil(to!float(number) / to!float(partitionSize))) - 1;
		
		// Determine if a new partition starts:
		if(number % partitionSize == 1) {
	    		// A new partition: Allocate memory for six entries.
	    		partitions[partitionIndex].length = partitionSize;
		}
		
		// Store the numbers into the partition:
		//writefln("Debug: %d into part. %d, index %d", number, partitionIndex, numberIndex); // Debugging
		partitions[partitionIndex][numberIndex] = number;

		// Determine the next index:
		numberIndex = number % partitionSize;
	}

    	writeln("Done partitioning the numbers.");

    	// Define a concurrent receiver for interim values:
    	auto receiverInterimTid = spawn(function void(Tid owner, size_t countInterimValues) {
	
		auto mainResult = BigInt("1");
	    	for(auto n = countInterimValues; n > 0; n--) {
			auto received = receiveOnly!BigInt();
			mainResult *= received;
		}

		owner.send(mainResult);
    	}, thisTid(), partitions.length);
    	setMaxMailboxSize(receiverInterimTid, 10000, OnCrowding.block);
    
    	writeln("Start calculating.");

    	// Run parallel:
    	foreach(partition; parallel(partitions)) {
		auto bigResult = BigInt("1");
		foreach(number; partition) {
	    		if(number > 0) {
		    		bigResult *= number;
		    	}
		}

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
