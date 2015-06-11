import 'dart:html';
//import 'package:paper_elements/paper_input.dart';
import 'package:polymer/polymer.dart';
//import 'dart:js';
import 'dart:svg';
import 'dart:math';

abstract class Node {
  draw();
  
  List _containeds = [];
  
  List get containeds => _containeds;
  
  num x;
  num y;

  num get getX => x;
  num get getY => y;
  
  SvgElement get getSvgElement;
  
  List movementListeners = [];
  
  List get getMovementListeners => movementListeners;
}

class Transition extends Node {

  SvgElement svg;
  
  String name = "Transition";
  
  bool selected = false;
  
  num _width = 150;
  num _height = 50;
  
  num get width => _width;
  num get height => _height;
  
  var dragStart;
  
  //EllipseElement ellipse;
  RectElement ell;
  SvgElement get getSvgElement => ell;
  
  Transition(x, y, svg) {
    this.x = x - 75;
    this.y = y - 75;
    this.svg = svg;
    draw();
  }

  
  draw() {
    ell = new RectElement();
    ell.attributes['x'] = x.toString();
    ell.attributes['y'] = y.toString();
    ell.attributes['height'] = height.toString();
    ell.attributes['width'] = width.toString();
    //ell.style.setProperty("fill", "red");
    ell.attributes['stroke'] = "black";
    ell.style.setProperty("fill", "white");
    ell.attributes['stroke'] = "black";
    ell.attributes['fill-opacity'] = "0.5";
    ell.style.setProperty("z-index", "100");
    //ell.attributes['fill-opacity'] = "0.0";
    
    /*TextElement te = new TextElement();
        te.text = name;
        te.attributes['x'] = (x+5).toString();
        te.attributes['y'] = (y+25).toString();
      */      

    var nameElement = new ContainedText(name, TextType.name, x, y, 5, 15);
    var guardElement = new ContainedText("[]", TextType.guard, x, y, 140, -20);
    var codeSegment = new ContainedText("input();  output();     action();", TextType.codeSegment, x, y, 100, 50);
    
    ell.onDragEnd.listen((event){
      print("dragged: "+event.client.toString());
    });
    
    ell.onClick.listen((event){
      print("clicked");
    });
    
    ell.onMouseDown.listen((event){
          print("down: "+event.client.toString());
          selected = true;
          dragStart = event.client; 
    });
    
    ell.onMouseUp.listen((event){
              print("up"+ event.client.toString());
        selected = false;          
    });
    
    ell.onMouseMove.listen((event){
      if(selected){
        x = x - (dragStart.x - event.client.x);
        y = y - (dragStart.y - event.client.y);
        dragStart = event.client;
        ell.attributes['x'] = x.toString();
        ell.attributes['y'] = y.toString();
        //te.attributes['x'] = (x+5).toString();
        //te.attributes['y'] = (y+25).toString();
        movementListeners.forEach((closure) => closure(this));
        containeds.forEach((item) {
          item.reposition(x,y);
        });
      }
    });
    
    //ell.onDoubleClick((event){
    //  print("clicked");
    //});
    
    
    svg.append(ell);
    //svg.append(te);
    nameElement.addToSvg(svg);
    guardElement.addToSvg(svg);
    codeSegment.addToSvg(svg);
    
    containeds.addAll([nameElement, guardElement, codeSegment]);
  }

}


class Place extends Node{

  SvgElement svg;
  String name = "place";
  EllipseElement ellipse;

  SvgElement get getSvgElement => ellipse;
  
  num rx = 100;
  num ry = 50;
  
  bool selected = false;
  var dragStart;
    
  
  Place(x, y, svg) {
    this.x = x;
    this.y = y;
    this.svg = svg;
    draw();
  }

  
  
  draw() {
    ellipse = new EllipseElement();
    ellipse.attributes['cx'] =  x.toString();
    ellipse.attributes['cy'] = y.toString();
    ellipse.attributes['rx'] = rx.toString();
    ellipse.attributes['ry'] = ry.toString();
    ellipse.attributes['render-order'] = "1";

    ellipse.style.setProperty("fill", "white");
    ellipse.attributes['stroke'] = "black";
    ellipse.attributes['fill-opacity'] = "0.5";
    ellipse.style.setProperty("z-index", "100");

        
    /*ForeignObjectElement textFO = new ForeignObjectElement();
    ParagraphElement para = new ParagraphElement();
    para.appendText(name);
    para.attributes['contentEditable'] = "true";
    para.attributes['x'] = (x - 50).toString();
    para.attributes['y'] = (y).toString();
    textFO.append(para);
    textFO.attributes['x'] = (x - 50).toString();
    textFO.attributes['y'] = (y-30).toString();
    textFO.attributes['width'] = "125";
    textFO.attributes['height'] = "150";    */

    
    var nameElement = new ContainedText(name, TextType.name, x, y, -30, -30);
    //var guardElement = new ContainedText("[]", TextType.name, x, y, 50, 40);
    //var codeSegment = new ContainedText("input();\noutput()\n;action();", type, x, y, -40, -70);
    
    ellipse.onMouseDown.listen((event){

      selected = true;
      dragStart = event.client; 
    });
        
    ellipse.onMouseUp.listen((event){

      selected = false;          
    });
        
    ellipse.onMouseMove.listen((event){
          if(selected){
            
            x = x - (dragStart.x - event.client.x);
            y = y - (dragStart.y - event.client.y);
            dragStart = event.client;
            ellipse.attributes['cx'] = x.toString();
            ellipse.attributes['cy'] = y.toString();
            movementListeners.forEach((closure) => closure(this));
            containeds.forEach((item) {
              item.reposition(x,y);
            });
          }
    });

        
    svg.append(ellipse);
    //svg.append(textFO);
    nameElement.addToSvg(svg);
    //guardElement.addToSvg(svg);
    //containeds.add(new ContainedElement(textFO, x - 50, y-30, -50, -30));
    containeds.add(nameElement);
  }

}

enum TextType {
  name,
  inscription,
  guard,
  codeSegment,
}


class ContainedText {
  String _text;
  ContainedElement _containedElem;
  var container;
  
  
  TextType _type;
  
  ContainedText(text, type, x, y, offsetX, offsetY){
    _type = type;
    _text = text;
    
    ForeignObjectElement textFO = new ForeignObjectElement();
        ParagraphElement para = new ParagraphElement();
        para.appendText(text);
        para.attributes['contentEditable'] = "true";
        //para.attributes['x'] = (x +offsetX).toString();
        //para.attributes['y'] = (y).toString();
        textFO.append(para);
        textFO.attributes['x'] = (x + offsetX).toString();
        textFO.attributes['y'] = (y + offsetY).toString();
        textFO.attributes['width'] = "125";
        textFO.attributes['height'] = "150";    

    
    _containedElem = new ContainedElement(textFO, x, y, offsetX, offsetY);  
  }
  
  void addToSvg(svgElement){
    container = svgElement;
    svgElement.append(_containedElem.element);
  }
  
  void reposition(x,y){
    _containedElem.reposition(x,y); 
  }
}



class ContainedElement{
  num _x, _y, _offsetX, _offsetY;
  SvgElement _element;
  
  ContainedElement(this._element, this._x, this._y, this._offsetX, this._offsetY);
    
  void reposition(num x, num y){
    this.x = x; 
    this.y = y;
    element.attributes['x'] = (x+offsetX).toString();
    element.attributes['y'] = (y+offsetY).toString();
  }
  
  SvgElement get element => _element;
  set element(SvgElement element){ _element = element;} 
  
  num get x => _x;
  set x(num x){_x = x;}
  num get y => _y;
  set y(num y){_y = y;}
  
  num get offsetX => _offsetX;
  set offsetX(num offsetX){_offsetX = offsetX;}
  num get offsetY => _offsetY;
  set offsetY(num offsetY) {_offsetY = offsetY;} 
}