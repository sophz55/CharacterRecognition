import java.util.*;

class ProjectiveTransform {

  int projWidth; //width of projection
  int projHeight; //height of projection

  PImage original; 
  PImage projection; 

  Point[] scope; //field of original that is being projected, each array in the 2d array is a vertex of the scope
  Point p1 = new Point(0, 0, 1);
  Point p2 = new Point(projWidth, 0, 1); 
  Point p3 = new Point(projWidth, projHeight, 1);
  Point p4 = new Point(0, projHeight, 1); 


  int chosen; //index in the scope array of the vertex of the scope that is selected

  Matrix TM; //matrix to multiply each vector point by

  ProjectiveTransform( PImage img ) {
    original = img;
    size(original.width * 2, original.height);
    projWidth = original.width;
    projHeight = original.height;
    scope = new Point[] {
      new Point(0, 0, 1), 
      new Point(projWidth, 0, 1), 
      new Point(projWidth, projHeight, 1), 
      new Point(0, projHeight, 1)
    };
    projection = createImage(projWidth, projHeight, RGB);
    updateTransform();
  }

  void updateTransform() {
    TM = transformMatrix( p1, p2, p3, p4, scope[0], scope[1], scope[2], scope[3]);
  }

  void display() {
    original.loadPixels();
    projection.loadPixels();

    updateTransform();

    for (int y = 0; y < projHeight; y++) {
      for (int x = 0; x < projWidth; x++) {
        Point p = new Point(x, y, 1);
        float[] vect = TM.multVector(p.getVector());
        int finalX = round(vect[0] / vect[2]);
        if (finalX < 0)
          finalX = original.width - finalX;
        finalX = finalX % original.width;

        int finalY = round(vect[1] / vect[2]);
        if (finalY < 0)
          finalY = original.height - finalY;
        finalY = finalY % original.height;

        projection.pixels[x + y * projection.width] = original.pixels[finalX + finalY * original.width];
      }
    }


    original.updatePixels();
    projection.updatePixels();

    image(original, 0, 0);
    image(projection, original.width, 0);   

    for (int i = 0; i < 4; i++) {
      int j = (i+1) % scope.length;
      fill(0);
      line(scope[i].x, scope[i].y, scope[j].x, scope[j].y);
    }
  }


  Matrix transformMatrix(Point ai, Point bi, Point ci, Point di, Point af, Point bf, Point cf, Point df) {
    Matrix t = qMatrix(af, bf, cf, df).multMatrix(qMatrix(ai, bi, ci, di).inverse());
    return t;
  }

  Matrix qMatrix(Point a, Point b, Point c, Point d) {
    float[][] temp = new float[][] { 
      { 
        a.x, b.x, c.x
      }
      , { 
        a.y, b.y, c.y
      }
      , { 
        a.z, b.z, c.z
      }
    };
    Matrix m = new Matrix(temp);
    float[] dVector = d.getVector();
    float[] multipliers = m.inverse().multVector( dVector );
    for (int i = 0; i < 3; i++)
      for (int j= 0; j < 3; j++)
        m.matrix[i][j] *= multipliers[j];
    return m;
  }
}

