import 'dart:html';
//import 'package:paper_elements/paper_input.dart';
import 'package:polymer/polymer.dart';
//import 'dart:js';
import 'dart:svg';
import 'dart:math';

import 'node.dart';

class Arc  {
  
  SvgElement svg;
  
  Node from;
  Node to;
  
  PolylineElement  line;
  
  
  
  String inscription;
  
  Arc(from, to, svg){
    this.from = from;
    this.to = to;
    this.svg = svg;
    
    draw();
  }
  
  draw(){
     line = new PolylineElement();
     line.attributes['stroke'] = "black";
     
     
     line.attributes['render-order'] = "-1";
     
     line.style.setProperty("z-index", "-100");
     line.style.setProperty("stroke", "black");
     line.style.setProperty("stroke-width", "2");
     
     line.attributes['marker-end'] = "url(#markerArrow)";
     
     from.getMovementListeners.add( (item) => resetPoints());
     to.getMovementListeners.add( (item) => resetPoints());
          
     
     svg.nodes.insert(0,line);
     resetPoints();
     
     
     
  }
  
  void resetPoints(){
    print("resetPoints 1");
    num fromX, fromY, toX, toY;
   
     
     
    
    List fromPoints, toPoints;
    print("resetPoints 2");
    if(from is Place){
      fromX = from.getX;
      fromY = from.getY;
      fromPoints = ellipseLineIntersect(from,fromX,fromY,to.getX,to.getY   );
    } else if(from is Transition){
      fromX = (from.getX + 75);
      fromY = (from.getY + 25);
      
      fromPoints = [ [from.getX + 75,
                     from.getY+ 25]
                    ];
    }
    print("resetPoints 3");
    if(to is Place){
      toX = to.getX;
      toY = to.getY;
      toPoints = ellipseLineIntersect(to,to.getX,to.getY,from.getX,from.getY   );
    } else if(to is Transition){
      toX = (to.getX + 75) ;
      toY = (to.getY + 25) ;
      
     
      toPoints = [ rectangleLineIntersect(to, fromX, fromY, toX, toY) ];
      print("toPoints: " + toPoints.toString());
    }
    print("resetPoints 4");
    
    line.attributes['points'] = ""+fromPoints[0][0].toString()+
        ","+fromPoints[0][1].toString()+" "+toPoints[0][0].toString()+","+toPoints[0][1].toString();
    
  }
 
  
  List rectangleLineIntersect(Transition trans, num fromX, num fromY, num toX, num toY){
    print("rectangleLineIntersect1");
    var RLines = [
      {'fromX': trans.getX, 'fromY': trans.getY, 'toX': trans.getX + trans.width, 'toY': trans.getY},
      {'fromX': trans.getX, 'fromY': trans.getY, 'toX': trans.getX, 'toY': trans.getY + trans.height},
      {'fromX': trans.getX + trans.width, 'fromY': trans.getY + trans.height, 'toX': trans.getX + trans.width, 'toY': trans.getY},
      {'fromX': trans.getX + trans.width, 'fromY': trans.getY + trans.height, 'toX': trans.getX, 'toY': trans.getY + trans.height},
    ];
    
    print("rectangleLineIntersect2");
    for(var l in RLines) {
      print(l);
      List intersect = lineIntersect(fromX, fromY, toX, toY, 
                       l['fromX'], l['fromY'], l['toX'], l['toY']);
      print("rectangleLineIntersect2.1");
      if(intersect.length > 0) return intersect;
      print("rectangleLineIntersect2.2");
    }
    print("rectangleLineIntersect3");
    return [];
  }
  
  List lineIntersect(num p0_x, num p0_y, num p1_x, num p1_y, 
                     num p2_x, num p2_y, num p3_x, num p3_y){
    print("lineIntersect1");
    num i_x, i_y;
    
    num s1_x, s1_y, s2_x, s2_y;
    print("lineIntersect3");    
    s1_x = p1_x - p0_x;     
    s1_y = p1_y - p0_y;
    s2_x = p3_x - p2_x;     
    s2_y = p3_y - p2_y;
    print("lineIntersect3");
        num s, t;
        s = (-s1_y * (p0_x - p2_x) + s1_x * (p0_y - p2_y)) / (-s2_x * s1_y + s1_x * s2_y);
        t = ( s2_x * (p0_y - p2_y) - s2_y * (p0_x - p2_x)) / (-s2_x * s1_y + s1_x * s2_y);
        print("lineIntersect4");
        var collision = [];
        if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
        {
            // Collision detected
            
            i_x = p0_x + (t * s1_x);
            i_y = p0_y + (t * s1_y);
            
            collision =  [i_x, i_y];
        }
        print("lineIntersect5");
        return collision; // No collision
    
  }
  
  //
  //Inspired by: http://csharphelper.com/blog/2012/09/calculate-where-a-line-segment-and-an-ellipse-intersect-in-c/
  
  List ellipseLineIntersect(Place place, fromX, fromY, toX, toY){
    // Translate so the ellipse is centered at the origin.
    num cx = place.getX;
    num cy = place.getY;
    
    fromX -= cx;
    fromY -= cy;
    toX -= cx;
    toY -= cy;
    
    num a = place.rx;
    num b = place.ry; 
    
    // Calculate the quadratic parameters.
    num A = (toX - fromX) * (toX - fromX) / a / a +
       (toY - fromY) * (toY - fromY) / b / b;
 
    num B = 2 * fromX * (toX - fromX) / a / a +
       2 * fromY * (toY - fromY) / b / b;
 
    num C = fromX * fromX / a / a + fromY * fromY / b / b - 1;

    // Make a list of t values.
    List<num> t_values = [];

    // Calculate the discriminant.
    num discriminant = B * B - 4 * A * C;
    if (discriminant == 0){
      // One real solution.
      t_values.add(-B / 2 / A);
    } else if (discriminant > 0){
      // Two real solutions.
      t_values.add(((-B + sqrt(discriminant)) / 2 / A));
      t_values.add(((-B - sqrt(discriminant)) / 2 / A));
    }
    
    List points = [];
    for (num t in t_values) {
      // If the points are on the segment (or we
      // don't care if they are), add them to the list.
      if (((t >= 0) && (t <= 1))) {
        num x = fromX + (toX - fromX) * t + cx;
        num y = fromY + (toY - fromY) * t + cy;
        points.add([x,y]);
      }
    }
    // Return the points.
    return points;
  }
}
