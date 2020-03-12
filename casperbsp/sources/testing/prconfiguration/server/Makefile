# the compiler to use
CC = gcc

# compiler flags:
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  =-Wall
  
#files to link:
LIBFLAGS =
  
# the name to use for both the target source file, and the output file:
TARGET = prconfigserver
  
all:$(TARGET)
  
$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c $(LIBFLAGS)

clean:
	rm $(TARGET).o $(TARGET)
