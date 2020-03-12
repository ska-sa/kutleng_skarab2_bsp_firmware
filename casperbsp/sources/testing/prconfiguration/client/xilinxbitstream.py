#! /usr/bin/python2.7

from ctypes import *
prloaderlib = CDLL("./libxilinxbitstream.so")

def main():
	
	prloaderlib.prbitstreamloader("192.168.1.13", 10000, "Hello World 123456078")
	exit() 
main() 
