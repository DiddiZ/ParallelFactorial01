module src.factorial01; 

import std.bigint;
import std.conv;
import std.stdio;
import std.parallelism;
import std.array;
import std.math;
import std.concurrency;
import std.range;

public void factorial01(int n) {
	// Catch the special cases:
	if(n == 0 || n == 1) {
		writefln("%d!=1", n);
		return;
	}

	// Set the number of CPUs for processing:
	auto countCPUs = totalCPUs * 2; // 2x because of hyper-threadding of modern Intel CPUs. totalCPUs returns only the physical number of cores.
	writefln("The calculation will run on %d CPUs.", countCPUs);
	TaskPool taskPool = new TaskPool(countCPUs);

	auto partResults = taskPool.workerLocalStorage(BigInt(1));

	writeln("Start calculating.");
	foreach (i; taskPool.parallel(iota(1,n+1), 1000)) {
		partResults.get *= i;
	}
	taskPool.finish();
	
	// total partial results
	BigInt total = BigInt(1);
	foreach (partResult; partResults.toRange) {
		total *= partResult;
	}

	// Print result
	writeln("Done calculating.");
	writeln("Prepare formatting and printing.");
	writefln("%d!~2^%d", n, total.uintLength()*32);
}
