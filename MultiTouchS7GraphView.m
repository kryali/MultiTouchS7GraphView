//
//  MultiTouchS7GraphView.m
//  Admin Mask
//
//  Created by Chas Conway on 11/23/10.
//  Copyright 2010 004 Technologies, USA. All rights reserved.
//

#import "MultiTouchS7GraphView.h"


@implementation MultiTouchS7GraphView

/*
 
	THIS CLASS SEPARATES THE TOUCH RESPONDERS FROM THE S7GRAPHVIEW
	SO THAT IT CAN RESPOND TO UICONTROL UITOUCHEVENTS NORMALLY, WHILE THIS ONE HANDLES
	MULTI TOUCH GESTURES
 
*/

- (id)init
{
	if( self = [super init])
		currentTouches = [[NSMutableArray alloc] init];
	return self;
}

#pragma mark -
#pragma mark MultiTouch Functions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
		
	NSArray * array = [touches allObjects];
	
	if([array count] == 1){
		//NSLog(@"Single touch event began!");
		UITouch * touch = [array objectAtIndex:0];
		CGPoint point = [touch locationInView:self];
		self.leftLineX = point.x;
		[currentTouches addObject:touch];
		//NSLog(@"currentTouches+: %d", [currentTouches count]);
		[self setNeedsDisplay];
	}
	else if([array count] == 2){		
		CGFloat max = 0.0f;
		CGFloat min = 0.0f;
		//NSLog(@"Multi touch event began!");
		for( int i = 0; i < [array count]; i++){
			UITouch * touch = [array objectAtIndex:i];
			[currentTouches addObject:touch];
			//NSLog(@"currentTouches+: %d", [currentTouches count]);
			CGPoint point = [touch locationInView:self];
			if(i==0){
				max = point.x;
				min = point.x;
			} else{
				if(point.x > max){
					max = point.x;
				}
				else if(point.x < min) {
					min = point.x;
				}
			}
		}
		self.leftLineX = min;
		self.rightLineX = max;
		//NSLog(@"Touch %f, %f", max, min);
		
		[self setNeedsDisplay];
	}
	
}

- (void)printCurrentTouches{
	for(int i=0; i< [currentTouches count]; i++){
		UITouch * touch = [currentTouches objectAtIndex:i];
		CGPoint newTouch = [touch locationInView:self];
		//NSLog(@"%d:%f\n", i, newTouch.x);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
	CGFloat max = 0.0f;
	CGFloat min = 0.0f;
	
	for( int i = 0; i < [currentTouches count]; i++){
		UITouch * touch = [currentTouches objectAtIndex:i];
		CGPoint point = [touch locationInView:self];
		if(i==0){
			max = point.x;
			min = point.x;
		} else{
			if(point.x > max){
				max = point.x;
			}
			else if(point.x < min) {
				min = point.x;
			}
		}
	}
	self.leftLineX = min;
	if([currentTouches count]==2)
		self.rightLineX = max;
	
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
		
	NSArray * array = [touches allObjects];
	if([array count] == 1){
		//NSLog(@"Single touch event ended!");
		self.leftLineX = -1;
		self.rightLineX = -1;
		[currentTouches removeObject:[array objectAtIndex:0]];
		//NSLog(@"currentTouches-: %d", [currentTouches count]);
		[self setNeedsDisplay];
	}
	if([array count] == 2){
		self.leftLineX = -1;
		self.rightLineX = -1;
		//NSLog(@"Multi touch event ended!");
		
		 for( int i = 0; i < [array count]; i++){
		 //NSLog(@"Touch %@", [array objectAtIndex:i]);
			 [currentTouches removeObject:[array objectAtIndex:i]];
		 }
		[self setNeedsDisplay];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
		
	//NSLog(@"Touch was cancelled!");
}

/*
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	NSLog(@"Draw Rect!");
}*/

- (void) dealloc{
	[currentTouches release];
	[super dealloc];
}

@end
