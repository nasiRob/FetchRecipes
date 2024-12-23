### Steps to Run the App
- **Simulator**: Run the app on the iOS Simulator. Best performance observed on iPhone 16 and later models.
- **First Launch**: On first run, an intentional error state appears to demonstrate the app's error handling. Tap 'Retry' to proceed.
- Tap retry and we will see the application 
- Tap on Apam Balik In the detail view long press the text! see translations inline
Sort and filter buttons on top right.

List:
Sort from A to Z or from Z to A
Filter by Cuisine Type. Or if they have a video attached
Tap on list item to go to detail view

Grid:
Wanted to show off the grid view here with the small image and the cuisin type in the corner
Caching the image data using coredata here. App is funtional without network

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?

Focused on Storage and offline capabilites. I Immediatatly cache the recipe response as json data in userdefaults. we update the data every launch but the user wouldnt know that since we initiall show cached data
Core data for storing image data. I wanted to show off the use of core data here instead of just user defaults. in my opinion user default could have been fine for the small images they dont take up a ton of space but for rule of thumb 
we should use core data for data types and structured data

I also used core data for the large image caching in the detail view i think this is the correct move since these can be quite large and we dont have to fetch them in batches... 
I made the decision to only update the images only if the cached image was over added/updated 24 hours from when the user has looked at it. I made the assumption that these images wont change often, but this can be adjusted as we see fit.

I also but some focus on having the multiple views to showcase different functionality. Lists are good for sorting and filter and the grid is good to quickly see the images if something looks and and you want to make it.


### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

I spent about 5 hours working on this project a lot of time went into data management and ensuring that the user experience was top notch and fluid. Using apple guidlines and apple components
I did not spend too much creating custom components/views and wanted to just use the basics. 

We have the Youtube link so i wanted to use that to create a custom playing inside of our app.. We want to keep users enganged in our app so i didnt want to deeplink out for video. We also use LPMeta data get get some more info on the recipes from the youtube videos. 

I left an hour at the end for testing. Depending on the project and how fleshed out the requirements are I will sometimes do the testing first and allow them to fail and then write the viewmodels and views.
for this case it was pretty fluid on how the app will functions so i had to leave time at the end to write tests for the viewmodels. 

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

Memory! If you tap on every single recipe on the list you will have all of that image data in core data.. If i had more time i would have created some sort of recycling capability where we only store 10 images at a time.
what this would do in unload old images and only keep the most recent ones that were tapped.
For smaller images something similar with a much higher threashold since they dont take up much space at all maybe 50/60

I think saving the response in the user defaults is great though its just text, and does not use too much memory... 
From the user experience point of view, if they arent concened about memory then this is the right approach for the most fluid app since we dont have to rely on the network for images.


### Weakest Part of the Project: What do you think is the weakest part of your project?

Error and loading states I could have spent more time giving good/actionable errors to the user, and having loading states to let the user know that we are working on something.

Core data clean up. Mentioned this earlier but yeah definitely lacking the core data / userdefault cleanup. It was in the back of my mind but i wanted to make sure all the funtionality was there before doing all the clean up
esstially more time would have been needed. I would go on to say that this would be crucial for anything to be released to the public and it was a mistake waiting to get this done but given more time it would have been great!


### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered

- **Future Plans**: Intend to implement a dynamic data cleanup mechanism to handle a larger cache size more efficiently. Further improvements in error handling and user feedback are also planned.
- Logging could have created a protocol but decided against it.. But essentially everyone logs errors and warnings differently but we would have wanted to set that up

