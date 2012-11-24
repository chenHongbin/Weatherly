Weatherli is a fully functional weather app that uses the free.worldweatheronline.com api to show you the weather with a minimalist design. It also uses the Climacons from Adam Whitcroft. 

![Smaller icon](http://dribbble.s3.amazonaws.com/users/14268/screenshots/553778/attachments/41129/weather-explained.jpg "Title here")

I originally saw this design on dribble, a user names Eddie Lobanovskiy created some shots of this [really creative idea for a simple weather app.] (http://dribbble.com/lobanovskiy/projects/60255-Brisk-Weather-App) Almost the same day I saw it I started developing it and in 2 days I had a pretty good working version down. 

I contacted him about working together to release it, and it turns out he found someone else to work with. 4 months later, it is no where to be found, and the app I wrote has been collecting virtual dust in a dropbox folder, so today, I am open sourcing this project for anyone to pick it up and learn from. PLEASE don't submit it to the Appstore…if you do you are a heartless soul who will be ostracized from the open source community for ages… ;)

One more thing, the app can be written better. I wrote this a few months ago, with very, very little time and my development skills have really refined in that time. 


The app basically contains 2 NSMutableArrays of rectangle UIViews, one array for all the rectangles above the current index, and one for all the rectangles slow the index. When the current index is set, a slew of animation blocks animate the 2 arrays of rectangles into place. As soon as the new index is set, both sets f rectangles fly off the screen. Then we either add/remove the current number if rectangles above/below the new current index, and they fly back in. 

![Smaller icon](http://dribbble.s3.amazonaws.com/users/14268/screenshots/553778/weather.jpg
 "Title here")


**Here is how to app works**

This app uses encodeWithCoder and decodeWithCoder to save the weather data. It really isn't that important to save the data locally because the user will only care about the weather now, not what the weather was 5 days ago. 

The weatherItem object has the following .h file 

	@interface WeatherItem : NSObject <NSCoding>
	{
    
	}
	@property (nonatomic) int indexForWeatherMap;
	@property (nonatomic, strong) NSString *weatherCurrentTemp;
	@property (nonatomic, strong) NSArray *nextDays;

	@property (nonatomic, strong) UIImage *weatherCurrentTempImage;
	@property (nonatomic, strong) NSString *weatherCurrentDay;
	@property (nonatomic, strong) NSArray *weatherForecast;
	@property (nonatomic, strong) NSArray *weatherForecastConditions;
	@property (nonatomic, strong) NSArray *weatherForecastConditionsImages;

	@property (nonatomic, strong) NSString *weatherCode;
	@property (nonatomic, strong) NSString *weatherPrecipitationAmount;
	@property (nonatomic, strong) NSString *weatherHumidity;
	@property (nonatomic, strong) NSString *weatherWindSpeed;


	-(id)initWithCurrentTemp:(NSString *)currentTemp currentDay:(NSString *)currentDay Forecast:(NSArray *)forecast andForecastConditions:(NSArray *)forecastConditions;

The app has a locationGetter class that fetches the location and informs its delegate (the weatherManager class) when it recieves a new location update. The weatherManager class then constructs the correct url with the new location and fetches weather data using the weather api. 

	pragma mark LocationDelegateMethods 

	- (void) newPhysicalLocation:(CLLocation *)location;
	{   
    //Get the zipcode using CLGeocoder
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:
    ^(NSArray *placemarks, NSError *error) {
        if (placemarks)
        {
            MKPlacemark *placemark = [placemarks objectAtIndex:0];
            
            NSString *zip = [placemark.addressDictionary objectForKey:@"ZIP"];

            NSString *queryString = [NSString stringWithFormat:@"http://free.worldweatheronline.com/feed/weather.ashx?q=%@&format=json&num_of_days=5&key=c0901b281c095607121605", zip];
            
            
            [self executeFetchForQueryString:queryString];
        } else if (error)
        {
            NSLog(@"Error getting zipcode from geocoder: %@", error.localizedDescription);
        }
    }];
	}

It fetches and parses the weather data then gives it to the WeatherViewController, where it sets the current index of the weather item.


	-(void)executeFetchForQueryString:(NSString *)queryString
	{    
    queryString = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Create JSONData using the string 
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:queryString] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    //Results from JSON Data 
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonData 
                                                            options:kNilOptions
                                                              error:&error];    
    WeatherItem *item = [WeatherItem itemFromWeatherDictionary:results];
    if (self.delegate)
    {        
        //Save in NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
        [defaults setObject:data forKey:@"currentItem"];
        
        [self.delegate didRecieveAndParseNewWeatherItem:item];
    }
	}	

There are 12 different rectangles the weather can fit in, each one corresponding to an interval of weather temperatures. Depending on which interval the current temperature is, the view controller sets the weather to the correct index and creates the rectangles above/under the current index. 

IN the viewDidLoad method, we set the right number of rectsngles above and below 

	//Top Rectangles, above the currentTemperature Rectangle
    CGFloat y =0;
    for (float i = 0; i < indexOfCurrentTempString; i++) {
        UIColor *color = [self.colorsArray     objectAtIndex:i];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320, kheightOfSmallRectangles)];
        view.backgroundColor = color;
        y+= view.bounds.size.height;
        
        [self.view addSubview:view];
        [self.topSmallRectangleViews addObject:view];
    }
    
    //CurrentTemperature ScrollView Rectangle
    UIColor *color = [self.colorsArray objectAtIndex:indexOfCurrentTempString];
        
    self.largeRectangleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, 320, 220)];
    self.largeRectangleScrollView.pagingEnabled = YES;
    self.largeRectangleScrollView.showsHorizontalScrollIndicator = NO;
    
    self.largeRectangleScrollView.contentSize = CGSizeMake(640, 220);
    self.largeRectangleScrollView.backgroundColor = color;
    y = self.largeRectangleScrollView.frame.size.height +y;
    
    //Bottom rectangles below our current Temperature Rectangle 
    for (float i = indexOfCurrentTempString +1; i < 13; i++) {
        UIColor *color = [self.colorsArray     objectAtIndex:i];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y-kOffsetForAnimationWhenTapped, 320, kheightOfSmallRectangles)];
        view.backgroundColor = color;
        y+= view.frame.size.height;
        [self.view addSubview:view];
        [self.bottomSmallRectangleViews addObject:view];
    } 

When we set the index of the new weather item, here is the animation block that makes it look pretty.

	-(void)setIndexOfCurrentTempString:(int)index
	{
    //Animations
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         //Remove top and bottom views to expose the current temperature view 
                        for (int i=0; i<self.bottomSmallRectangleViews.count; i++)
                         {
                             UIView *view = [self.bottomSmallRectangleViews objectAtIndex:i];
                             [view setFrame:CGRectMake(0, +500, 320, kheightOfSmallRectangles)];
                         }
                         
                         for (int i=0; i<self.topSmallRectangleViews.count; i++)
                         {
                             UIView *view = [self.topSmallRectangleViews objectAtIndex:i];
                             [view setFrame:CGRectMake(0, -1000, 320, kheightOfSmallRectangles)];
                         }    
                     } 
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.25
                                               delay:0.0
                                             options: UIViewAnimationCurveEaseOut
                                          animations:^{
                                              //Animate the current temperature view into its new location 
                                              CGFloat y = index * kheightOfSmallRectangles;
                                              [self.largeRectangleScrollView setFrame:CGRectMake(0, y, 320, 220)];
                                              self.largeRectangleScrollView.backgroundColor = [self.colorsArray objectAtIndex:index];
                                              self.detailView.backgroundColor = [self.colorsArray objectAtIndex:index];
                                              self.drawerView.backgroundColor = [self.colorsArray objectAtIndex:index];
                                          } 
                                          completion:^(BOOL finished){
                                             
                                              if (self.soundsEnabled){
                                                  
                                                   [[SoundManager sharedSoundManager] playSwooshSound];
                                              } else {
                                                  //Do Nothing 
                                              }
                                             
                                              
                                              [UIView animateWithDuration:0.4
                                                                    delay:0.0
                                                                  options: UIViewAnimationCurveEaseIn
                                                               animations:^{
                                                                   //Add Top rectangle views above current temperature view 
                                                                   [self.topSmallRectangleViews removeAllObjects];
                                                                   
                                                                   CGFloat y =0;
                                                                   for (float i = 0; i < index; i++) {
                                                                       UIColor *color = [self.colorsArray     objectAtIndex:i];
                                                                
                                                                       UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y -500, 320, kheightOfSmallRectangles)];
                                                                       view.alpha = 0;
                                                                       view.backgroundColor = color;
                                                                       y+= view.bounds.size.height;
                                                                       
                                                                       [self.view addSubview:view];
                                                                       [self.topSmallRectangleViews addObject:view];
                                                                       
                                                                       [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
                                                                           
                                                                    [view setFrame:CGRectMake(0, y-kheightOfSmallRectangles, 320, kheightOfSmallRectangles)];
                                                                           
                                                                           view.alpha = 1;

                                                                       }completion:^(BOOL finished){
                                                                           
                                                                       }]; 
                                                                   }
                                                                   y = self.largeRectangleScrollView.frame.size.height +y;
                                                                   
                                                                   //Add bottom rectangle views below current temperature view 
                                                                   [self.bottomSmallRectangleViews removeAllObjects];

                                                                   for (float i = index +1; i < 13; i++) {
                                                                       UIColor *color = [self.colorsArray     objectAtIndex:i];
                                                                       
                                                                       UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y+500, 320, kheightOfSmallRectangles)];
                                                                       view.alpha = 0;
                                                                       view.backgroundColor = color;
                                                                       y+= view.frame.size.height;
                                                                       [self.view addSubview:view];
                                                                       [self.bottomSmallRectangleViews addObject:view];
                                                                       [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
                                                                           
                                                                           [view setFrame:CGRectMake(0, y-kOffsetForAnimationWhenTapped - kheightOfSmallRectangles, 320, kheightOfSmallRectangles)];
                                                                    
                                                                           view.alpha = 1;
                                                                           
                                                                       }completion:^(BOOL finished){
                                                                           
                                                                       }];         
                                                                   } 
                                                               } 
                                                               completion:^(BOOL finished){
                                                               }];
                                          }];
                     }];
    }
    self.isChangingIndex = NO;
}

Check out the app and let me know if you have any questions.  Copyright 2012- Ahmed Eid. This app is distributed under the terms of the GNU General Public License. 

Cheers! 
