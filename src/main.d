import std.bigint;
import std.conv;
import std.stdio;
import std.parallelism;
import std.array;
import std.math;
import std.concurrency;
import std.range;

int main(string[] args) {
	if(args.length != 2) {
		writeln("Please provide a number for which the factorial should be calculated.");
		return 1;
	}

	// Read n:
	auto n = to!uint(args[1]);

	// Catch the special cases:
	if(n == 0 || n == 1) {
		writefln("%d!=1", n);
		return 0;
	}

	// Set the number of CPUs for processing:
	auto countCPUs = totalCPUs * 2; // 2x because of hyper-threadding of modern Intel CPUs. totalCPUs returns only the physical number of cores.
	writefln("The calculation will run on %d CPUs.", countCPUs);
	defaultPoolThreads(countCPUs);

	auto partResults = taskPool.workerLocalStorage(BigInt(1));

	writeln("Start calculating.");
	foreach (i; parallel(iota(1,n+1))) {
		partResults.get *= i;
	}

	// total partial results
	BigInt total = BigInt(1);
	foreach (partResult; partResults.toRange) {
		total *= partResult;
	}

	// Print result
	writeln("Done calculating.");
	writeln("Prepare formatting and printing.");
	writefln("%d!=%s", n, total.toDecimalString());

	return 0;
}
