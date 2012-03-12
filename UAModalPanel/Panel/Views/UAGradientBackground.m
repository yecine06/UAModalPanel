//
//  UAGradientBackground.m
//  UAModalPanel
//
//  Created by Matt Coneybeare on 1/8/12.
//  Copyright (c) 2012 Urban Apps. All rights reserved.
//

#import "UAGradientBackground.h"

@implementation UAGradientBackground

@synthesize gradientStyle, lineMode;

- (id)initWithFrame:(CGRect)frame style:(UAGradientBackgroundStyle)aStyle color:(CGFloat *)components location:(CGFloat *)locations locationSize:(CGFloat)locsize lineMode:(UAGradientLineMode)lineModes {
	if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.autoresizesSubviews = YES;
		self.backgroundColor = [UIColor clearColor];
		gradientStyle = aStyle;
		lineMode = lineModes;

        locationSize = locsize;
		colorComponents = NSZoneMalloc(NSDefaultMallocZone(), locationSize*sizeof(CGFloat));
        locationComponents  = NSZoneMalloc(NSDefaultMallocZone(), locationSize*sizeof(CGFloat));
		for (int i = 0; i < locationSize; i++) {
			//DebugLog(@"%f", components[i]);
			colorComponents[i] = components[i];
            locationComponents[i] = locations[i];
		}
	}
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UAGradientBackgroundStyle)aStyle color:(CGFloat *)components lineMode:(UAGradientLineMode)lineModes {
    CGFloat locations[2] = { 0.0, 1.0 };
    return [self initWithFrame:frame style:aStyle color:components location:locations locationSize:2 lineMode:lineModes];
}

- (id)initWithFrame:(CGRect)frame color:(CGFloat *)components {
	return [self initWithFrame:frame style:UAGradientBackgroundStyleLinear color:components lineMode:NO];
}
- (id)initWithFrame:(CGRect)frame style:(UAGradientBackgroundStyle)aStyle {
	CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0 };
    return [self initWithFrame:frame style:aStyle color:components lineMode:UAGradientLineModeNone];
}
- (id)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame style:UAGradientBackgroundStyleLinear];
}


+ (id)gradientWithFrame:(CGRect)frame style:(UAGradientBackgroundStyle)aStyle color:(CGFloat *)components location:(CGFloat *)locations locationSize:(CGFloat)locsize lineMode:(UAGradientLineMode)lineModes{
    
    return [[[UAGradientBackground alloc] initWithFrame:frame style:aStyle color:components location:locations locationSize:locsize lineMode:lineModes] autorelease];
}

+ (id)gradientWithFrame:(CGRect)frame style:(UAGradientBackgroundStyle)aStyle color:(CGFloat *)components lineMode:(UAGradientLineMode)lineModes {
	return [[[UAGradientBackground alloc] initWithFrame:frame style:aStyle color:components lineMode:lineModes] autorelease];
}
+ (id)gradientWithFrame:(CGRect)frame color:(CGFloat *)components {
	return [[(UAGradientBackground *)[UAGradientBackground alloc] initWithFrame:frame color:components] autorelease];
}
+ (id)gradientWithFrame:(CGRect)frame style:(UAGradientBackgroundStyle)aStyle {
	return [[[UAGradientBackground alloc] initWithFrame:frame style:aStyle] autorelease];
}
+ (id)gradientWithFrame:(CGRect)frame; {
	return [[[UAGradientBackground alloc] initWithFrame:frame] autorelease];
}


- (void)setColorComponents:(CGFloat *)components {
	for (int i = 0; i < 8; i++) {
		colorComponents[i] = components[i];
	}
}

- (void)setLocationComponents:(CGFloat *)locations {
	for (int i = 0; i < 8; i++) {
		locationComponents[i] = locations[i];
	}
}

- (void)setColorComponents:(CGFloat *)components andLocationComponents:(CGFloat *)locations andLocationSize:(CGFloat)locsize {
    NSZoneFree(NSDefaultMallocZone(), colorComponents);
    NSZoneFree(NSDefaultMallocZone(), locationComponents);    
    locationSize = locsize;
    colorComponents = NSZoneMalloc(NSDefaultMallocZone(), locationSize*4*sizeof(CGFloat));
    locationComponents  = NSZoneMalloc(NSDefaultMallocZone(), locationSize*sizeof(CGFloat));    

	for (int i = 0; i < locsize; i++) {
		colorComponents[i*4] = components[i*4];
		colorComponents[i*4+1] = components[i*4+1];
		colorComponents[i*4+2] = components[i*4+2];
		colorComponents[i*4+3] = components[i*4+3];        
		locationComponents[i] = locations[i];        
    }
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	CGPoint start = CGPointMake(rect.size.width/2, rect.size.height/2);
	
	switch (gradientStyle) {
		case UAGradientBackgroundStyleRadial: {
			CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorspace, colorComponents, locationComponents, locationSize);
			double a = rect.size.width/2.0;
			double b = rect.size.height/2.0;
			double h = sqrt(a*a + b*b);
			CGContextDrawRadialGradient(context, myGradient, start, 0, start, h, 0);
			CGGradientRelease(myGradient);
			break;
		}
		case UAGradientBackgroundStyleRadialReversed: {
            int arraySize = locationSize*4;
			CGFloat reversed[arraySize];
            
            for (int i = 0; i < locationSize; i++) {
                int reverseIndex = locationSize - 1 -i;
                reversed[reverseIndex] = colorComponents[i*4];
                reversed[reverseIndex+1] = colorComponents[reverseIndex+1];
                reversed[reverseIndex+2] = colorComponents[reverseIndex+2];
                reversed[reverseIndex+3] = colorComponents[reverseIndex  +3];
            }
            
			CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, reversed, locationComponents, locationSize);
			double a = rect.size.width/2.0;
			double b = rect.size.height/2.0;
			double h = sqrt(a*a + b*b);
			CGContextDrawRadialGradient(context, myGradient, start, 0, start, h, 0);
			CGGradientRelease(myGradient);
			break;
		}
		case UAGradientBackgroundStyleLinear: {
			CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, colorComponents, locationComponents, locationSize);
			CGContextDrawLinearGradient(context, myGradient, CGPointMake(0.0,0.0), CGPointMake(0.0,rect.size.height+10), 0);
			CGGradientRelease(myGradient);
			break;
		}
		case UAGradientBackgroundStyleLinearReversed: {
			CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, colorComponents, locationComponents, locationSize);
			CGContextDrawLinearGradient(context, myGradient, CGPointMake(0.0,rect.size.height+1), CGPointMake(0.0,0.0), 0);
			CGGradientRelease(myGradient);
			break;
		}
		case UAGradientBackgroundStyleCenterHighlight: {
			CGFloat myLocations[3] = { 0.0, 0.5, 1.0 };
			CGFloat myColorComponents[12] = { colorComponents[0], colorComponents[1], colorComponents[2], colorComponents[3], colorComponents[4], colorComponents[5], colorComponents[6], colorComponents[7], colorComponents[0], colorComponents[1], colorComponents[2], colorComponents[3] };
			CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, myColorComponents, myLocations, 3);
			CGContextDrawLinearGradient(context, myGradient, CGPointMake(0.0,0.0), CGPointMake(0.0,rect.size.height+1), 0);
			CGGradientRelease(myGradient);
			break;
		}
		default:
			break;
	}
	CGColorSpaceRelease(myColorspace);
	
	if (lineMode & UAGradientLineModeTop ||
		lineMode & UAGradientLineModeTopAndBottom) {
		// top Line
		CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
		CGContextMoveToPoint(context, 0, 0);
		CGContextAddLineToPoint(context, self.frame.size.width, 0);
		CGContextStrokePath(context);
	}
	if (lineMode & UAGradientLineModeBottom ||
		lineMode & UAGradientLineModeTopAndBottom) {
		// bottom line
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
		CGContextMoveToPoint(context, 0, self.frame.size.height);
		CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
		CGContextStrokePath(context);		
	}
}


- (void)dealloc {
	NSZoneFree(NSDefaultMallocZone(), colorComponents);
	[super dealloc];
}


@end


