//
//  matrix_functions.h
//  OpenGL1
//
//  Created by Mark Herman, II on 8/25/13.
//
//

#ifndef OpenGL1_matrix_functions_h
#define OpenGL1_matrix_functions_h

void crossProduct(float *a, float *b, float *res);
void normalize(float *a);
void setIdentityMatrix( float *mat, int size);
void multMatrix(float *a, float *b);
void setTranslationMatrix(float *mat, float x, float y, float z);

#endif
