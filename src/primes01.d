module src.primes01; 

import std.conv;
import std.stdio;
import std.parallelism;
import std.array;
import std.math;
import std.concurrency;
import std.range;

//Computes the number of primes until n
public void primes01(int n) {
	// Catch the special cases:
	if(n < 2) {
		writefln("Primes til %d: 0", n);
		return;
	}

	// Set the number of CPUs for processing:
	auto countCPUs = totalCPUs * 2; // 2x because of hyper-threadding of modern Intel CPUs. totalCPUs returns only the physical number of cores.
	writefln("The calculation will run on %d CPUs.", countCPUs);
	TaskPool taskPool = new TaskPool(countCPUs);

	auto partResults = taskPool.workerLocalStorage(0);

	writeln("Start calculating.");
	foreach (num; taskPool.parallel(iota(2,n+1))) {
		int i = 2; 
		while(i <= num) { 
			if(num % i == 0)
				break;
			i++; 
		}
		if(i == num)
			partResults.get++;
	}
	taskPool.finish();

	// total partial results
	writeln("Totaling partial results.");
	auto total = 0;
	foreach (partResult; partResults.toRange) {
		total += partResult;
	}

	// Print result
	writeln("Done calculating.");
	writeln("Prepare formatting and printing.");
	writefln("Primes til %d: %d", n, total);
}
