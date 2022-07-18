#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, const char* argv[]) {
  if (argc < 2) {
    printf("usage: %s <string> [offset] [max-length]\n", argv[0]);
    return 1;
  }

  unsigned long length = strlen(argv[1]);

  if (length == 0) {
    return 0;
  }

  unsigned long size = length;
  unsigned long offset = 0;

  if (argc > 2) {
    offset = atoi(argv[2]);
  }

  if (argc > 3) {
    size = atoi(argv[3]);
  }

  if (size <= 0) {
    return 0;
  } else if (length < size) {
    printf("%s", argv[1]);
    return 0;
  }

  char output[size + 1];
  unsigned long index = 0;
  while (index < size) {
    output[index] = argv[1][(index + offset) % length];
    index++;
  }

  output[size] = '\0';

  printf("%s", output);
  return 0;
}
