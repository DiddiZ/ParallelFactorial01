import std.bigint;
import std.conv;
import std.stdio;
import std.parallelism;
import std.array;
import std.math;
import std.concurrency;
import std.range;
import src.factorial01;
import src.factorial02;
import src.factorial03;
import src.primes01;
import core.time;

int main(string[] args) {
	if(args.length != 3) {
		writeln("Please select a calculation and provide number for which the factorial/primes should be calculated.");
		return 1;
	}

	// Read n:
	auto n = to!uint(args[2]);

	auto startTime = MonoTime.currTime();

	final switch (args[1])
	{
		case "factorial01":
			factorial01(n);
			break;
		case "factorial02":
			factorial02(n);
			break;
		case "factorial03":
			factorial03(n);
			break;
		case "primes":
			primes01(n);
			break;
	}	
	
	writefln("Computation took %f ms", ticksToNSecs( MonoTime.currTime().ticks - startTime.ticks)/1000000.0);
	
	
	return 0;
}
