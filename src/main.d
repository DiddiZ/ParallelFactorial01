import std.bigint;
import std.conv;
import std.stdio;
import std.parallelism;
import std.array;
import std.math;
import std.concurrency;
import std.range;
import src.factorial01;
import src.primes01;

int main(string[] args) {
	if(args.length != 3) {
		writeln("Please select a calculation and provide number for which the factorial/primes should be calculated.");
		return 1;
	}

	// Read n:
	auto n = to!uint(args[2]);

	final switch (args[1])
	{
		case "factorial":
			factorial01(n);
			break;
		case "primes":
			primes01(n);
			break;
	}	
	return 0;
}
