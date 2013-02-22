/*
 * genetica.d
 * 
 * Copyright 2013 m1kc <m1kc@yandex.ru>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 */


import std.stdio;

immutable ubyte NOOP = 0x00;
immutable ubyte POP  = 0x01;
immutable ubyte MOV  = 0x02;
immutable ubyte ADD  = 0x03;
immutable ubyte PUSH = 0x04;

immutable uint MAX_INSTRUCTIONS = 10;

ubyte[][] awesome;

int run(ubyte[] code, int[] stack, bool transcript, bool traceStack, bool traceErrors)
{
	try
	{
		int ax,bx;
		for(uint i=0; i<code.length; i++)
		{
			if (transcript) write(i,": ");
			ubyte instr = code[i];
			switch(code[i])
			{
				case NOOP:
					if (transcript) write("NOOP");
					break;
				case POP:
					if (transcript) write("POP ");
					i++;
					switch(code[i])
					{
						case 0x00:
							if (transcript) write("AX");
							ax = stack[$-1];
							stack = stack[0..$-1];
							break;
						case 0x01:
							if (transcript) write("BX");
							bx = stack[$-1];
							stack = stack[0..$-1];
							break;
						default:
							if (transcript) write("{",code[i],"}");
					}
					break;
				case MOV:
					if (transcript) write("MOV //");
					break;
				case ADD:
					if (transcript) write("ADD ");
					i++;
					int wut;
					switch(code[i])
					{
						case 0x00:
							if (transcript) write("AX");
							wut = ax;
							break;
						case 0x01:
							if (transcript) write("BX");
							wut = bx;
							break;
						default:
							if (transcript) write("{",code[i],"}");
					}
					if (transcript) write(" to ");
					i++;
					switch(code[i])
					{
						case 0x00:
							if (transcript) write("AX");
							ax += wut;
							break;
						case 0x01:
							if (transcript) write("BX");
							bx += wut;
							break;
						default:
							if (transcript) write("{",code[i],"}");
					}
					break;
				case PUSH:
					if (transcript) write("PUSH ");
					i++;
					switch(code[i])
					{
						case 0x00:
							if (transcript) write("AX");
							stack ~= ax;
							break;
						case 0x01:
							if (transcript) write("BX");
							stack ~= bx;
							break;
						default:
							if (transcript) write("{",code[i],"}");
					}
					break;
				default:
					if (transcript) write("{",instr,"}");
					break;
			}
			if (transcript) writeln;
			if (traceStack) writeln(stack,"ax=",ax,"bx=",bx);
		}
		int ret = stack[$-1];
		return ret;
	}
	catch(Throwable ex)
	{
		if (traceErrors) writeln(ex.toString());
		return int.max;
	}
}

bool isAwesome(ubyte[] code)
{
	int result1 = run(code,[2,3],false,false,false);
	int result2 = run(code,[4,5],false,false,false);
	return (result1 == 5 && result2 == 9);
}

void recurse(ubyte[] code, int index)
{
	if (index >= MAX_INSTRUCTIONS)
	{
		if (isAwesome(code))
		{
			write("+");
			awesome ~= code.dup;
		}
		else
		{
			//write(".");
		}
	}
	else
	{
		for (ubyte j=0; j<=PUSH; j++)
		{
			if (index==0) { write("1"); stdout.flush(); }
			if (index==1) { write("2"); stdout.flush(); }
			code[index] = j;
			recurse(code, index+1);
		}
	}
}

int main(string[] args)
{
	ubyte[MAX_INSTRUCTIONS] code;
	code[] = NOOP;
	recurse(code, 0);
	/+
			code[0] = POP;
			code[1] = 0x01;
			+ pop
			+ bx
			code[2] = ADD;
			code[3] = 0x01;
			code[4] = 0x01;
			code[5] = PUSH;
			code[6] = 0x01;
	+/
	writeln;
	foreach(ubyte[] c; awesome)
	{
		int result1 = run(c,[2,3],true,false,true);
		writeln("==> ",result1);
		int result2 = run(c,[4,5],true,false,true);
		writeln("==> ",result2);
	}
	return 0;
}

