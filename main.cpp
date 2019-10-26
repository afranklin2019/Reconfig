// Greg Stitt
// University of Florida
// main.cpp
//

#include <iostream>
#include <cstdlib>
#include <cassert>
#include <cstring>
#include <cstdio>
#include <vector>

#include "Board.h"

using namespace std;

#define TEST_SIZE 10000
//#define DEBUG

#define GO_ADDR 	0
#define N_ADDR      	1
#define RESULT_ADDR	2
#define DONE_ADDR   	3

unsigned fibonacci(unsigned n);




int main(int argc, char* argv[]) {
  
  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " bitfile" << endl;
    return -1;
  }
  
  vector<float> clocks(Board::NUM_FPGA_CLOCKS);
  clocks[0] = 100.0;
  clocks[1] = 100.0;
  clocks[2] = 100.0;
  clocks[3] = 100.0;
  
  cout << "Programming FPGA...." << endl;

  // initialize board
  Board *board;
  try {
    board = new Board(argv[1], clocks);
  }
  catch(...) {
    exit(-1);
  }

  const unsigned go_set   = 1;
  const unsigned go_clear = 0;

  unsigned result_hw = 0, result_sw = 0;

  unsigned done = 0;



    for (unsigned i = 1; i < 30 ; i++) {

        // Write N to the FPGA
        board->write(&i, N_ADDR, 1);

        // Assert go signal
        board->write(&go_set, GO_ADDR, 1);

        // Clear go signal
        board->write(&go_clear, GO_ADDR, 1);

        // Check done signal
        while(!done)
        {
            board->read(&done, DONE_ADDR, 1);
        }

        done = 0;

        // Read result from FPGA
        board->read(&result_hw, RESULT_ADDR, 1);

        // Get software fibonacci result
        result_sw = fibonacci(i);

        // Print hardware and software results
        cout << i << ": HW = " << result_hw << ", SW = " << result_sw << endl;
  }
  
  
  return 1;
}

unsigned fibonacci(unsigned n)
{
    unsigned temp = 0;
    unsigned i = 3;
    unsigned x = 1;
    unsigned y = 1;

    while(i < n)
    {
        temp = x + y;
        x = y;
        y = temp;
        i++;

    }

    return y;

}