class Matrix {
  int numCols;
  int numRows;
  float[][] matrix; //row heavy!!!

  Matrix() {
    numCols = 3;
    numRows = 3;
    matrix = new float[numRows][numCols];
  }

  Matrix(float[][] els) {
    numCols = 3;
    numRows = 3;
    matrix = els;
  }

  float[] multVector( float[] vector ) {
    float[] v = new float[numRows];
    for (int row = 0; row < numRows; row++)
      v[row] = dotProduct(matrix[row], vector );
    return v;
  }

  float dotProduct( float[] v1, float[] v2 ) {
    float sum = 0;
    for (int i = 0; i < v1.length; i++)
      sum += v1[i]*v2[i];
    return sum;
  }

  Matrix multScalar( float scalar ) {
    Matrix m = new Matrix();
    for (int i = 0; i < numRows; i++)
      for (int j = 0; j < numCols; j++)
        m.matrix[i][j] = matrix[i][j] * scalar;
    return m;
  }

  Matrix multMatrix( Matrix other ) {
    Matrix m = new Matrix();
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        m.matrix[i][j] = 
          matrix[i][0] * other.matrix[0][j] + 
          matrix[i][1] * other.matrix[1][j] + 
          matrix[i][2] * other.matrix[2][j];
    return m;
  }

  Matrix inverse() {
    Matrix m = cofactor().transpose();
    return m.multScalar( 1 / determinant() );
  }

  float determinant() {
    return dotProduct(cofactor().matrix[0], matrix[0]);
  }

  Matrix cofactor() {

    /* float[][] blah = new float[][] {
     {
     matrix[1][1] * matrix[2][2] - matrix[2][1]* matrix[1][2], 
     (matrix[1][0] * matrix[2][2] - matrix[1][2]* matrix[2][0])*(-1), 
     matrix[1][0] * matrix[2][1] - matrix[2][0]* matrix[1][1]
     }
     , 
     {
     (matrix[0][1] * matrix[2][2] - matrix[2][1]* matrix[0][2])*(-1), 
     (matrix[0][2] * matrix[2][0] - matrix[0][0]* matrix[2][2])*(-1), 
     (matrix[0][1] * matrix[2][0] - matrix[2][1]* matrix[0][0])
     }
     , 
     {
     matrix[0][1] * matrix[1][2] - matrix[1][1]* matrix[0][2], 
     matrix[1][0] * matrix[0][2] - matrix[0][0]* matrix[1][2], 
     matrix[1][1] * matrix[0][0] - matrix[0][1]* matrix[1][0]
     }
     };
     Matrix result = new Matrix(blah);*/

    Matrix result = new Matrix();
    int a, b, c, d;
    for (int row = 0; row < 3; row++) {
      a = (row+1) % numRows;
      b = (a+1) % numRows;
      for (int col = 0; col < 3; col++) {
        c = (col+1) % numCols;
        d = (c+1) % numCols;
        result.matrix[row][col] = (matrix[a][c]*matrix[b][d] - matrix[b][c]*matrix[a][d]);
      }
    }
    return result;
  }
s
  Matrix transpose() {
    Matrix m = new Matrix();
    for (int i = 0; i < numRows; i++)
      for (int j = i; j < numCols; j++) {
        m.matrix[i][j] = matrix[j][i];
        if (i != j)
          m.matrix[j][i] = matrix[i][j];
      }
    return m;
  }
}

