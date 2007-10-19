#include<stdio.h> 
#include<math.h> 
#include<stdlib.h> 
#define MAX_BUF 10000 

int main( int argc, char *argv[] ) { 
  int n = 0; 
  double min = 0.0; 
  double max = 0.0; 
  int size = 0; 
  double d = 0.0; 
  double data = 0.0; 
  int freq[ 10 ]; 
  int maxfreq; 
  double g2 = 0.0; 
  char Line[ MAX_BUF ]; 
  int k; 
  
  if( argc != 4 ) { 
    fprintf( stderr, "Usage: generate mean sd count\n" ); 
    exit( EXIT_FAILURE ); 
  } 
 
 if( sscanf(argv[1], "%lf", &min) != 1 ) { 
    fprintf( stderr, "min is not numeric\n" );
    exit( EXIT_FAILURE );
  } 

  if( sscanf(argv[2], "%lf", &max) != 1 ) {
    fprintf( stderr, "max is not numeric\n" );
    exit( EXIT_FAILURE ); 
  } 

  if( sscanf(argv[3], "%d", &size) != 1 ) { 
    fprintf( stderr, "size is not numeric\n" ); 
    exit( EXIT_FAILURE ); 
  }

  for( k=0; k<10; k++ ) freq[k] = 0;

  d = ( max - min ) / 10.0;

  while( fgets(Line, MAX_BUF, stdin) ) { 

    if( sscanf(Line,"%lf",&data) == 1 ) { 

      if( data < min ) continue; 
      if( data > max ) continue; 

      for( k=1; k<=10; k++ ) if( data < min + k*d ) { 
	freq[k-1]++;
	break; 
      }
    }
  } 

  maxfreq = freq[0]; 

  for( k=1; k<10; k++ ) { 
    if( freq[k] > maxfreq ) maxfreq = freq[k];
  }

  for( k=0; k<10; k++ ) { 
    int t, c = (int)(size * ( (double)freq[k] )/maxfreq ); 

    printf( "%5.1f - %5.1f (%5d) : ", min+k*d, min+(k+1)*d, freq[k] );

    for( t = 0; t<c; t++ ) putchar( '*' ); 

    putchar( '\n' );
  }
  return EXIT_SUCCESS;
}
