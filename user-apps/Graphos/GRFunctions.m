#import "GRFunctions.h"
#include <math.h>
#include <unistd.h>

#define GD_PI 3.14159265358979323846

NSPoint pointApplyingCostrainerToPoint(NSPoint p, NSPoint sp)
{
	float cos22 = cos(GD_PI * 22 / 180);
	float cos45 = cos(GD_PI * 45 / 180);
	float cos67 = cos(GD_PI * 67 / 180);
	double cy22, cy45, cy67, diffx, diffy;
	NSPoint cp;

	diffx = max(p.x, sp.x) - min(p.x, sp.x);
	diffy = max(p.y, sp.y) - min(p.y, sp.y);

	cy22 = diffx * pow(1 - pow(cos22, 2), 0.5) / cos22;
	cy45 = diffx * pow(1 - pow(cos45, 2), 0.5) / cos45;
	cy67 = diffx * pow(1 - pow(cos67, 2), 0.5) / cos67;

	if(diffy < cy45) {
		cp.x = p.x;	
		if(diffy > cy22 && diffy < cy67) {
			if(p.y > sp.y)
				cp.y = sp.y + cy45;
			else 
				cp.y = sp.y - cy45;
		} else {
			cp.y = sp.y;
		}
	} else {
		cp.x = sp.x;
		cp.y = p.y;
	}
		
	return cp;
}

BOOL pointInRect(NSRect rect, NSPoint p)
{
	if(p.x >= rect.origin.x 
				&& p.x <= (rect.origin.x + rect.size.width)
				&& p.y >= rect.origin.y 
				&& p.y <= (rect.origin.y + rect.size.height))
		return YES;
					
	return NO;
}

double min(double a, double b) {
	if(a < b)
    	return a;
  	else
    	return b;
}

double max(double a, double b) {
  	if(a > b)
    	return a;
  	else
    	return b;
}

NSDictionary *pfbFilesInFontsDirs(NSArray *fontDirs)
{
	NSMutableDictionary *namesAndPaths;
	NSString *fontName, *pfbFilePath;
	int i, j;

	namesAndPaths = [NSMutableDictionary dictionaryWithCapacity: 1];

	for(i = 0; i < [fontDirs count]; i++) {
		NSString *fdir = [fontDirs objectAtIndex: i];
		NSString *str = [NSString stringWithContentsOfFile: fdir];
		if(str) {
			NSArray *lines = [str componentsSeparatedByString: @"\n"];
			fdir = [fdir stringByDeletingLastPathComponent];
			for(j = 0; j < [lines count]; j++) {
				NSString *line = [lines objectAtIndex: j];
				NSScanner *scanner = [NSScanner scannerWithString: line];
				[scanner setCharactersToBeSkipped: 
						[NSCharacterSet characterSetWithCharactersInString: @"/(); "]];
				if([scanner scanUpToString: @" " intoString: &fontName]
						&& [scanner scanUpToString: @")" intoString: &pfbFilePath]) {
					if([[pfbFilePath pathExtension] isEqualToString: @"pfb"]
							|| [[pfbFilePath pathExtension] isEqualToString: @"pfa"]) {
						pfbFilePath = [fdir stringByAppendingPathComponent: pfbFilePath];
						[namesAndPaths setObject: pfbFilePath forKey: fontName];
					}
				}
			}
		}
	}

	return namesAndPaths;
}

NSString *pfaDataOfBinaryFontAtPath(NSString *apath)
{
	NSString *pfa = nil;
  	int ch;
  	unsigned int count;
	FILE *fp, *fptmp;
	
  	fp = fopen([apath cString], "r");
  	fptmp = fopen("/tmp/pfatmp", "a");
	if(!fp || !fptmp) 
		return pfa; 
	
	while((ch = fgetc(fp)) != EOF) {
   	if(ch == 0x80) {
      	switch(fgetc(fp)) {
				case 1:
	  				count = fgetc(fp);
	  				count += (fgetc(fp) << 8);
	  				count += (fgetc(fp) << 16);
	  				count += (fgetc(fp) << 24);
	  				for(; count; count--) {
	    				ch = fgetc(fp);
	    				if(ch == EOF) 
							goto makestring;
	    				if(ch == '\r')
							ch = '\n';
						fputc(ch, fptmp);
	  				}
	  				break;
				case 2:
	  				count = fgetc(fp);
	  				count += (fgetc(fp) << 8);
	  				count += (fgetc(fp) << 16);
	  				count += (fgetc(fp) << 24);
	  				for(; count; count--) {
	    				ch = fgetc(fp);
	    				if(ch == EOF) 
							goto makestring;
	    				fprintf(fptmp, "%02x", ch);
	    				if(!(count % 35L))
							fputc('\n', fptmp);
	  				}
          		fputc('\n', fptmp);
	  				break;
				default:
	  				goto makestring;
			}
		} else {
			fputc(ch, fptmp);
		}
	}

makestring:
	fclose(fp);
	fclose(fptmp);
	pfa = [NSString stringWithContentsOfFile: @"/tmp/pfatmp"];
	unlink("/tmp/pfatmp");
	
	return pfa;
}
