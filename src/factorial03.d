module src.factorial03; 

import std.bigint;
import std.conv;
import std.stdio;
import std.parallelism;
import std.array;
import std.math;
import std.concurrency;
import std.range;

enum BATCH_SIZE = 10;

public void factorial03(int n) {
	// Catch the special cases:
	if(n == 0 || n == 1) {
		writefln("%d!=1", n);
		return;
	}

	writeln("Start calculating.");
	
	auto total = product(1, n);

	// Print result
	writeln("Done calculating.");
	writeln("Prepare formatting and printing.");
	writefln("%d!~2^%d", n, total.ulongLength()*64);
}

private BigInt product (int lowerBound, int upperBound) {
	// Multiply small batches serially
	if (upperBound - lowerBound < BATCH_SIZE) {
		BigInt prod = BigInt(lowerBound);
		for (int num = lowerBound +1; num <= upperBound; num++) {
			prod *= num;
		}
		return prod;
	}
	
	int middle = (lowerBound+upperBound)/2;
	auto parallelTask = task(&product ,lowerBound, middle);
	taskPool.put(parallelTask);
	return product(middle+1,upperBound) * parallelTask.yieldForce;
}