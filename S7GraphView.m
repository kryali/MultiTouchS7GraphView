//
//  S7GraphView.m
//  S7Touch
//
//  Created by Aleks Nesterow on 9/27/09.
//  aleks.nesterow@gmail.com
//  
//  Thanks to http://snobit.habrahabr.ru/ for releasing sources for his
//  Cocoa component named GraphView.
//  
//  Copyright © 2009, 7touchGroup, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  * Neither the name of the 7touchGroup, Inc. nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY 7touchGroup, Inc. "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL 7touchGroup, Inc. BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  

#import "S7GraphView.h"

@interface S7GraphView (PrivateMethods)

- (void)initializeComponent;

@end

@implementation S7GraphView

+ (UIColor *)colorByIndex:(NSInteger)index {
	
	UIColor *color;
	
	switch (index) {
		case 0: color = RGB(5, 141, 191);
			break;
		case 1: color = RGB(80, 180, 50);
			break;		
		case 2: color = RGB(255, 102, 0);
			break;
		case 3: color = RGB(255, 158, 1);
			break;
		case 4: color = RGB(252, 210, 2);
			break;
		case 5: color = RGB(248, 255, 1);
			break;
		case 6: color = RGB(176, 222, 9);
			break;
		case 7: color = RGB(106, 249, 196);
			break;
		case 8: color = RGB(178, 222, 255);
			break;
		case 9: color = RGB(4, 210, 21);
			break;
		default: color = RGB(204, 204, 204);
			break;
	}
	
	return color;
}

@synthesize dataSource = _dataSource, xValuesFormatter = _xValuesFormatter, yValuesFormatter = _yValuesFormatter;
@synthesize drawAxisX = _drawAxisX, drawAxisY = _drawAxisY, drawGridX = _drawGridX, drawGridY = _drawGridY;
@synthesize xValuesColor = _xValuesColor, yValuesColor = _yValuesColor, gridXColor = _gridXColor, gridYColor = _gridYColor;
@synthesize drawInfo = _drawInfo, info = _info, infoColor = _infoColor;

@synthesize rightLineX, leftLineX;	//Added by Kiran
@synthesize barColor = _barColor;
@synthesize detailFont = _detailFont;
@synthesize labelColor = _labelColor;
@synthesize	snappingEnabled;


- (id)initWithFrame:(CGRect)frame {
	
    if (self = [super initWithFrame:frame]) {
		[self initializeComponent];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	
	if (self = [super initWithCoder:decoder]) {
		[self initializeComponent];
	}
	
	return self;
}

- (void)dealloc {
	
	[_dataSource release];
	
	[_xValuesFormatter release];
	[_yValuesFormatter release];
	
	[_xValuesColor release];
	[_yValuesColor release];
	
	[_gridXColor release];
	[_gridYColor release];
	
	[_info release];
	[_infoColor release];
	
	[super dealloc];
}

- (void) displayBarBox: (CGSize) stringSize offsetY: (CGFloat) offsetY displayX: (CGFloat) displayX c: (CGContextRef) c valueString: (NSString *) valueString i:(NSInteger)i  {
			// Build the rounded rectangle box for the display
			
			UIColor * currentColor = [S7GraphView colorByIndex:i];
			CGRect displayBar;
			CGPoint topLeftCorner = CGPointMake(displayX, offsetY-stringSize.height);
			CGPoint bottomLeftCorner = CGPointMake(topLeftCorner.x, topLeftCorner.y+(_detailFont.pointSize+5.0));
			CGPoint topRightCorner = CGPointMake(topLeftCorner.x+stringSize.width+5.0, topLeftCorner.y);
			CGPoint bottomRightCorner = CGPointMake(topRightCorner.x, bottomLeftCorner.y);
			
			CGFloat radius = (bottomRightCorner.y - topRightCorner.y)/2;
			
			// Draw the arcs for the rounded box
			CGContextAddArc(c, topRightCorner.x, topRightCorner.y+radius, radius, 3.14/2, (3/2)*(3.14), 1);
			CGContextSetFillColorWithColor(c, currentColor.CGColor);
			CGContextFillPath(c);
			CGContextAddArc(c, topLeftCorner.x, topLeftCorner.y+radius, radius,  0, (2)*(3.14), 0);
			CGContextSetFillColorWithColor(c, currentColor.CGColor);
			CGContextFillPath(c);
						CGFloat displayY = (offsetY-stringSize.height);
			displayBar = CGRectMake(displayX, displayY, stringSize.width+5.0, _detailFont.pointSize+5.0);
			CGContextAddRect(c ,displayBar);
			CGContextFillRect(c, displayBar);
			
			CGContextSetFillColorWithColor(c, currentColor.CGColor);
			
			CGContextSetFillColorWithColor(c, _labelColor.CGColor);
			CGSize offset = CGSizeMake(-1.5, -1.5 );
			UIColor * shadow = RGB( 50, 50, 50);
			CGContextSetShadowWithColor(c, offset, 2, shadow.CGColor);
			[valueString drawInRect:displayBar withFont:_detailFont
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
			CGContextSetShadowWithColor(c, offset, 0, NULL);
			//NSLog(@"%@ - %f", valueString,[valueString sizeWithFont:_detailFont].width);
			CGContextSetFillColorWithColor(c, _xValuesColor.CGColor);

}
- (void)drawRect:(CGRect)rect {
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
	CGContextFillRect(c, rect);
	
	NSUInteger numberOfPlots = [self.dataSource graphViewNumberOfPlots:self];
	
	if (!numberOfPlots) {
		return;
	}
	
	CGFloat offsetX = _drawAxisY ? 60.0f : 10.0f;
	CGFloat offsetY = (_drawAxisX || _drawInfo) ? 20.0f : 10.0f;
	
	CGFloat minY = 0.0;
	CGFloat maxY = 0.0;
	
	UIFont *font = [UIFont systemFontOfSize:11.0f];
	
	for (NSUInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
		
		NSArray *values = [self.dataSource graphView:self yValuesForPlot:plotIndex];
		
		for (NSUInteger valueIndex = 0; valueIndex < values.count; valueIndex++) {
			
			if ([[values objectAtIndex:valueIndex] floatValue] > maxY) {
				maxY = [[values objectAtIndex:valueIndex] floatValue];
			}
		}
	}
	
	if (maxY < 100) {
		maxY = ceil(maxY / 10) * 10;
	} 
	
	if (maxY > 100 && maxY < 1000) {
		maxY = ceil(maxY / 100) * 100;
	} 
	
	if (maxY > 1000 && maxY < 10000) {
		maxY = ceil(maxY / 1000) * 1000;
	}
	
	if (maxY > 10000 && maxY < 100000) {
		maxY = ceil(maxY / 10000) * 10000;
	}
	
	CGFloat step = (maxY - minY) / 5;
	CGFloat stepY = (self.frame.size.height - (offsetY * 2)) / maxY;
	
	for (NSUInteger i = 0; i < 6; i++) {
		
		NSUInteger y = (i * step) * stepY;
		NSUInteger value = i * step;
		
		if (_drawGridY) {
			
			CGFloat lineDash[2];
			lineDash[0] = 6.0f;
			lineDash[1] = 3.0f;
			
			//CGContextSetLineDash(c, 0.0f, lineDash, 2);
			CGContextSetLineDash(c, 0, NULL, 0);
			CGContextSetLineWidth(c, 1.0f);
			
			CGPoint startPoint = CGPointMake(offsetX, self.frame.size.height - y - offsetY);
			CGPoint endPoint = CGPointMake(self.frame.size.width - offsetX/4, self.frame.size.height - y - offsetY);
			
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c, self.gridYColor.CGColor);
			CGContextStrokePath(c);
		}
		
		if (i > 0 && _drawAxisY) {
			
			NSNumber *valueToFormat = [NSNumber numberWithInt:value];
			NSString *valueString;
			
			if (_yValuesFormatter) {
				valueString = [_yValuesFormatter stringForObjectValue:valueToFormat];
			} else {
				valueString = [valueToFormat stringValue];
			}
			
			[self.yValuesColor set];
			CGRect valueStringRect = CGRectMake(0.0f, self.frame.size.height - y - offsetY, 50.0f, 20.0f);
			
			[valueString drawInRect:valueStringRect withFont:font
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
		}
	}
	
	NSUInteger maxStep;
	
	NSArray *xValues = [self.dataSource graphViewXValues:self];
	NSUInteger xValuesCount = xValues.count;
	
	if (xValuesCount > 5) {
		
		NSUInteger stepCount = 5;
		NSUInteger count = xValuesCount - 1;
		
		for (NSUInteger i = 4; i < 8; i++) {
			if (count % i == 0) {
				stepCount = i;
			}
		}
		
		step = xValuesCount / stepCount;
		maxStep = stepCount + 1;
		
	} else {
		
		step = 1;
		maxStep = xValuesCount;
	}
	
	CGFloat stepX = (self.frame.size.width - (offsetX * 5/4)) / (xValuesCount - 1);
	
	for (NSUInteger i = 0; i < maxStep; i++) {
		
		NSUInteger x = (i * step) * stepX;
		
		if (x > self.frame.size.width - (offsetX * 5/4)) {
			x = self.frame.size.width - (offsetX * 5/4);
		}
		
		NSUInteger index = i * step;
		
		if (index >= xValuesCount) {
			index = xValuesCount - 1;
		}
		
		if (_drawGridX) {
			
			CGFloat lineDash[2];
			
			lineDash[0] = 3.0f;
			lineDash[1] = 6.0f;
			
			CGContextSetLineDash(c, 0.0f, lineDash, 2);
			CGContextSetLineWidth(c, 1.0f);
			
			CGPoint startPoint = CGPointMake(x + offsetX, offsetY);
			CGPoint endPoint = CGPointMake(x + offsetX, self.frame.size.height - offsetY);
			
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c, self.gridXColor.CGColor);
			CGContextStrokePath(c);
		}
		
		if (_drawAxisX) {
			
			id valueToFormat = [xValues objectAtIndex:index];
			NSString *valueString;
			
			if (_xValuesFormatter) {
				valueString = [_xValuesFormatter stringForObjectValue:valueToFormat];
			} else {
				valueString = [NSString stringWithFormat:@"%@", valueToFormat];
			}
			
			[self.xValuesColor set];
			[valueString drawInRect:CGRectMake(x, self.frame.size.height - 20.0f, 120.0f, 20.0f) withFont:font
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
		}
	}
	
	stepX = (self.frame.size.width - (offsetX * 5/4)) / (xValuesCount - 1);
	
	CGContextSetLineDash(c, 0, NULL, 0);
	
	for (NSUInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
		
		NSArray *values = [self.dataSource graphView:self yValuesForPlot:plotIndex];
		BOOL shouldFill = NO;
		
		if ([self.dataSource respondsToSelector:@selector(graphView:shouldFillPlot:)]) {
			shouldFill = [self.dataSource graphView:self shouldFillPlot:plotIndex];
		}
		
		CGColorRef plotColor = [S7GraphView colorByIndex:plotIndex].CGColor;
		
		for (NSUInteger valueIndex = 0; valueIndex < values.count - 1; valueIndex++) {
			
			NSUInteger x = valueIndex * stepX;
			NSUInteger y = [[values objectAtIndex:valueIndex] intValue] * stepY;
			
			CGContextSetLineWidth(c, 1.5f);
			
			CGPoint startPoint = CGPointMake(x + offsetX, self.frame.size.height - y - offsetY);
			
			x = (valueIndex + 1) * stepX;
			y = [[values objectAtIndex:valueIndex + 1] intValue] * stepY;
			
			CGPoint endPoint = CGPointMake(x + offsetX, self.frame.size.height - y - offsetY);
			
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c, plotColor);
			CGContextStrokePath(c);
			
			if (shouldFill && plotIndex == 0) {
				
				CGContextMoveToPoint(c, startPoint.x, self.frame.size.height - offsetY);
				CGContextAddLineToPoint(c, startPoint.x, startPoint.y);
				CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
				CGContextAddLineToPoint(c, endPoint.x, self.frame.size.height - offsetY);
				CGContextClosePath(c);
				
				CGColorRef plotColor1 = CGColorCreateCopyWithAlpha(plotColor, 0.3);
				
				CGContextSetFillColorWithColor(c, plotColor1);
				
				CGColorRelease(plotColor1);
				
				CGContextFillPath(c);
			}
		}
	}
	
	
	if (_drawInfo) {
		
		font = [UIFont systemFontOfSize:10.0f];
		[self.infoColor set];
		[[_info uppercaseString] drawInRect:CGRectMake(0.0f, 5.0f, self.frame.size.width, 20.0f) withFont:font
			lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	}
	
#pragma mark MultiTouch methods
	
	NSArray *yValues = [self.dataSource graphView:self yValuesForPlot:0];		// User interaction only currently happens on the first plot
	
	CGFloat rightBounds = (stepX * ([yValues count]-1)) + offsetX + 10.0f;		//Add 7.0f for touch tolerance
	
	// Draw the left and right bars, Make sure that they are within the bounds of the graph
	if(leftLineX != -1 && leftLineX >= offsetX && leftLineX <= rightBounds){	
		// NSLog(@"\nLine Position: %f\n Frame Width: %f\n Calculated Bounds: %f", leftLineX, self.frame.size.width, self.frame.size.width-offsetX);
		// Set the left line to start from the beginning of the graph to the bottom of it 

		NSInteger leftIndex = (leftLineX-offsetX+(stepX/2))/stepX;
		NSInteger leftValue = -1;
		//NSLog(@"Index: %i", leftIndex);
		// Sanity Check
		if(leftIndex < [yValues count])
			leftValue = [[yValues objectAtIndex:leftIndex] intValue];
		
		_barColor = [S7GraphView colorByIndex:0];
		
		// Snapping v. Guessing
		if(snappingEnabled){
			// Set the position of the bar to the x equivalent of 
			leftLineX = leftIndex * stepX +offsetX;
		}
		else {
			if(leftIndex+1 < [yValues count]){
				// Interpolation
				NSInteger nextValue = [[yValues objectAtIndex:leftIndex+1]intValue];
				// Convert values and indexes to graph coordinates
				CGFloat startX = leftIndex * stepX;
				CGFloat endX = (leftIndex + 1) * stepX;
				//NSLog(@"\nSTART: %f\n END: %f", startX, endX);
				
				// Y = MX + B
				CGFloat slope = (nextValue-leftValue)/(endX-startX);// slope = Rise / Run
				CGFloat yintercept = leftValue-(startX*slope);		// yint = (startX)slope - value
				CGFloat currentX = leftLineX - offsetX;						
				
				// Interpolated Value = (slope)(X) + yintercept
				leftValue = slope*(leftLineX-offsetX) + yintercept;		
				//NSLog(@"\ncurrnetX: %f\nslope: %f\n yintercept: %f\ncalculated: %d", currentX, slope, yintercept, leftValue);					
			}
		}
		CGFloat yCoord = self.frame.size.height - (stepY*leftValue) - offsetY;
				
		CGContextSetLineWidth(c, 1.5f);								// width of the bars
		/*CGPoint startPoint = CGPointMake(leftLineX, offsetY);
		CGPoint endPoint = CGPointMake(leftLineX, self.frame.size.height-offsetY);
		
		// Build the path to the point
		CGContextMoveToPoint(c, startPoint.x, startPoint.y);
		CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
		CGContextClosePath(c);
		
		CGContextSetStrokeColorWithColor(c, _barColor.CGColor);
		//CGContextSetStrokeColorWithColor(c, self.gridYColor.CGColor);
		// Draw the path 
		CGContextStrokePath(c);*/
				
		CGFloat components[] = 
		{0,0,0,0};
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
		CGColorRef color = CGColorCreate(colorspace, components);
		CGContextSetFillColorWithColor(c, color);	
		
		// Wipe out the title bar
		CGRect titleOverlay = CGRectMake(offsetX, 0, rightBounds-
										 offsetX-10.0f, offsetY-1);
		CGContextAddRect(c, titleOverlay);
		CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
		CGContextFillRect(c, titleOverlay);
		
		// Wipe out the bottom bar
		CGFloat bottomOfGraph = self.frame.size.height - offsetY;
		CGRect bottomOverlay = CGRectMake(0, bottomOfGraph, self.frame.size.width, offsetY-1);
		CGContextAddRect(c, bottomOverlay);
		CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
		CGContextFillRect(c, bottomOverlay);
		
		CGRect dateRect = CGRectMake(offsetX, bottomOfGraph, rightBounds-offsetX-10.0f, offsetY-1);
		CGContextAddRect(c, dateRect);
		CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
		CGContextFillRect(c, dateRect);
				
		NSString * valueString = [NSString stringWithFormat:@"%d", leftValue];
		//NSString * valueString = [[NSString alloc] initWithFormat:@"%d", leftValue];
		CGRect displayBar;
		NSString * dateString;
		// NSLog(@"%d", leftValue);
		// If there is only one touch being handled, draw the box in a different position
		CGContextSetLineWidth(c, 2.5f);								// width of the bars
		
		
		if(rightLineX == -1){
			
			CGSize stringSize = [valueString sizeWithFont:_detailFont];
			CGFloat displayX = (leftLineX-stringSize.width/2);	
			if([self.dataSource graphViewNumberOfPlots:self] == 2){
				NSArray *yValues2 = [self.dataSource graphView:self yValuesForPlot:1];
				CGFloat	 displayX2 = (leftLineX+15);
				NSString * secondValueString = [NSString stringWithFormat:@"%d", [[yValues2 objectAtIndex:leftIndex] intValue]];
				CGSize stringSize2 = [secondValueString sizeWithFont:_detailFont];	
				[self displayBarBox: stringSize2 offsetY:offsetY displayX:displayX2 c:c valueString:secondValueString i:1];
				displayX = displayX - stringSize.width/2-20;
			}
			[self displayBarBox: stringSize offsetY: offsetY displayX: displayX c: c valueString: valueString i:0];

			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
			[dateFormatter setDateFormat:@"EEEE, MMMM d, yyyy"];
			dateString = [NSString stringWithFormat:(@"%@", [dateFormatter stringFromDate:[xValues objectAtIndex:leftIndex]])];
			[dateString drawInRect:dateRect withFont:_detailFont 
					 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
			
			[dateFormatter release];
			//NSString * dateString = [NSString stringWithFormat:@"%d", ];
		}
		if( rightLineX != -1 && rightLineX <= rightBounds && rightLineX >= offsetX){											// NSLog(@"Drawing line!");
																																//NSLog(@"2Index %f, %f", (leftLineX-offsetX)/stepX, (rightLineX-offsetX)/stepX)
	
			NSInteger rightIndex = (rightLineX-offsetX)/stepX;
			NSInteger rightValue = [[yValues objectAtIndex:rightIndex] intValue];
			CGFloat yCoord = self.frame.size.height - (stepY*rightValue) - offsetY;
			
			// FOR SNAPPING	- TODO: turn interpolation to a function
			if(snappingEnabled){
				rightLineX = rightIndex * stepX +offsetX;
				rightValue = rightValue - leftValue;
			}
			// FOR INTERPOLATION
			else {
				if(rightIndex+1 < [yValues count]){
					// Interpolation
					NSInteger nextValue = [[yValues objectAtIndex:rightIndex+1]intValue];
					// Convert values and indexes to graph coordinates
					CGFloat startX = rightIndex * stepX;
					CGFloat endX = (rightIndex + 1) * stepX;
					//NSLog(@"\nSTART: %f\n END: %f", startX, endX);
					// Y = MX + B
					CGFloat slope = (nextValue-rightValue)/(endX-startX);// slope = Rise / Run
					CGFloat yintercept = rightValue-(startX*slope);		// yint = (startX)slope - value
					
					// Interpolated Value = (slope)(X) + yintercept
					CGFloat currentX = rightLineX - offsetX;
					rightValue = slope*(currentX) + yintercept;	
					//NSLog(@"\ncurrnetX: %f\nslope: %f\n yintercept: %f\ncalculated: %d", currentX, slope, yintercept, leftValue);					
					rightValue = rightValue - leftValue;
				}
			}
			
			valueString = [NSString stringWithFormat:@"%d", rightValue];
			if(rightValue>0){
				valueString = [NSString stringWithFormat:@"+%@", valueString];
			}
			
			CGSize fontSize = [valueString sizeWithFont:_detailFont];
			
			
			
			//_barColor = RGB(60,60,60);
			//CGContextSetLineWidth(c, 1.0);		
			CGPoint startPoint = CGPointMake(leftLineX, offsetY+10);
			CGPoint endPoint = CGPointMake(rightLineX, offsetY+10);
			/*
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			CGContextSetStrokeColorWithColor(c, _barColor.CGColor);
			CGContextStrokePath(c);*/
			
			
			
			//_barColor = RGB(26,26,26);
			
			UIColor * boxColor = [S7GraphView colorByIndex:0];
			CGContextSetFillColorWithColor(c, boxColor.CGColor);
			CGFloat displayBarX = leftLineX+(rightLineX-leftLineX)/2-(fontSize.width/2);
			[self displayBarBox:fontSize offsetY:offsetY displayX:displayBarX c:c valueString:valueString i:0];
			/*
			if(rightValue < 0){
				//CGContextSetFillColorWithColor(c, [UIColor redColor].CGColor);
				//UIColor * red = RGB(255,56,56);
				UIColor * red = RGB(255,107,107);
				//CGContextSetFillColorWithColor(c, red.CGColor);
				
			}
			else{
				//UIColor * green = RGB(192,255,163);
				//CGContextSetFillColorWithColor(c, green.CGColor);
				//CGContextSetFillColorWithColor(c, [UIColor greenColor].CGColor);
			}
			//CGContextSetFillColorWithColor(c, _labelColor.CGColor);
			
			CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);
			[valueString drawInRect:displayBar withFont:_detailFont
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
			*/
			NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
			[dateFormatter setDateFormat:@"EEEE, MMMM d, yyyy"];
			CGContextSetFillColorWithColor(c, _xValuesColor.CGColor);
			
			
			NSArray *yValues2 = [self.dataSource graphView:self yValuesForPlot:1];
			NSInteger left = [[yValues2 objectAtIndex:leftIndex] intValue];
			NSInteger right = [[yValues2 objectAtIndex:rightIndex] intValue];
			NSString * secondValueString;
			if(right-left > 0)
				secondValueString = [NSString stringWithFormat:@"+%d", right-left];
			else {
				secondValueString = [NSString stringWithFormat:@"%d", right-left];
			}

			//if( left < 0 )
			//NSLog(@"2ND: %i-%i", left, right);
			CGSize stringSize2 = [secondValueString sizeWithFont:_detailFont];	
			[self displayBarBox:stringSize2 offsetY:offsetY+20 displayX:displayBarX c:c valueString:secondValueString i:1];

			dateString = [NSString stringWithFormat:(@"%@-%@", [dateFormatter stringFromDate:[xValues objectAtIndex:leftIndex]])];
			NSString * endDateString = [NSString stringWithFormat:(@"%@", [dateFormatter stringFromDate:[xValues objectAtIndex:rightIndex]])];
			NSString * finalDateString = [NSString stringWithFormat:(@"%@ - %@"), dateString, endDateString];
			//NSLog(@"%@", finalDateString);
			[finalDateString drawInRect:dateRect withFont:_detailFont 
					 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
			[dateFormatter release];
			CGContextSetLineWidth(c, 2.5f);		
			// Draw the right bar
			startPoint = CGPointMake(rightLineX, 0);
			endPoint = CGPointMake(rightLineX, self.frame.size.height);
			
			CGContextMoveToPoint(c, startPoint.x, offsetY);
			CGContextAddLineToPoint(c, endPoint.x, self.frame.size.height-offsetY);
			CGContextClosePath(c);
			CGContextSetStrokeColorWithColor(c, _barColor.CGColor);
			CGContextStrokePath(c);
			
			// Right marker
			CGRect marker = CGRectMake(rightLineX-5.0, yCoord-5.0, 10.0, 10.0);
			CGContextAddEllipseInRect(c, marker);
			CGContextSetStrokeColorWithColor(c, _barColor.CGColor);
			CGContextSetFillColorWithColor(c, _labelColor.CGColor);
			CGContextFillEllipseInRect(c, marker);
			CGContextStrokeEllipseInRect(c, marker);
			}
		
		CGPoint startPoint = CGPointMake(leftLineX, offsetY);
		CGPoint endPoint = CGPointMake(leftLineX, self.frame.size.height-offsetY);
		
		
		CGSize offset = CGSizeMake(1.0,1.0 );
		UIColor * shadow = RGB( 0, 0, 0);
		//CGContextSetShadowWithColor(c, offset, 2, shadow.CGColor);
		
		// Build the path to the point
		CGContextMoveToPoint(c, startPoint.x, startPoint.y);
		CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
		CGContextClosePath(c);
		
		CGContextSetStrokeColorWithColor(c, _barColor.CGColor);
		//CGContextSetStrokeColorWithColor(c, self.gridYColor.CGColor);
		// Draw the path 
		CGContextStrokePath(c);
		
		CGContextSetShadowWithColor(c, offset, 2, NULL);
		
		//CGContextSetShadowWithColor(c, offset, 1, shadow.CGColor);
		UIColor * markerColor = [[UIColor alloc]initWithWhite:1 alpha:1 ];
		CGRect marker = CGRectMake(leftLineX-5.0, yCoord-5.0, 10.0, 10.0);
		CGContextSetStrokeColorWithColor(c, _barColor.CGColor);
		CGContextSetFillColorWithColor(c, markerColor.CGColor);
		CGContextFillEllipseInRect(c, marker);
		CGContextStrokeEllipseInRect(c, marker);
		
	}
	
	
	
}

- (void)reloadData {
	
	[self setNeedsDisplay];
}

#pragma mark PrivateMethods

- (void)initializeComponent {
	_drawAxisX = YES;
	_drawAxisY = YES;
	_drawGridX = YES;
	_drawGridY = YES;   
	self.multipleTouchEnabled = YES;
	self.userInteractionEnabled = YES;
	_xValuesColor = [[UIColor blackColor] retain];
	_yValuesColor = [[UIColor blackColor] retain];
	snappingEnabled = YES;
	//_detailFont = [UIFont systemFontOfSize:15.0f];
	_detailFont = [UIFont fontWithName:@"Helvetica" size:15.0f];
	_gridXColor = [[UIColor blackColor] retain];
	_gridYColor = [[UIColor blackColor] retain];
	_barColor = [[UIColor blackColor] retain];
	_labelColor = [[UIColor whiteColor] retain];
	_drawInfo = NO;
	_infoColor = [[UIColor blackColor] retain];
}

@end
