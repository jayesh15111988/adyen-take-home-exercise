## Adyen Coding Challenge

### App Demo

https://user-images.githubusercontent.com/6687735/180144269-3a352cb0-53c6-4a1f-a02e-1f0cf79bfcfc.mov

## Overview

The aim of this project is to develop an iOS application to display the list venues around the user’s location

## Features

This app has a just one home screen that supports following features,

1. Venues List Screen

![Simulator Screen Shot - iPhone 12 - 2022-07-21 at 08 27 36](https://user-images.githubusercontent.com/6687735/180145307-a24756c2-e448-4eda-b820-97731129a302.png)

This screen has multiple functionalities,

1. User can tap on "Search venues at current location" button to trigger venues search at user's current location
2. User can vary the radius to control how far they want to search places
3. User can also control whether they want to sort the list by relevance or the distance from their current location (Both lists are sorted in the descending order)
4. User can also click on "Show full address" button to see the popup with venue's full address details
5. "Search venues at current location" button will disappear after firing the first request. In case any of the input parameters change (radius, sort preference, or location), the request will fire automatically to update search results


## Architecture

The app uses MVVM architecture. The reason is, I wanted to separate out all the business and data transformation logic away from the view layer. The view model is responsible for getting network models (Codable models) from network service and converting them into local view models to be consumed by the view layer.

The view model interacts with the network layer through protocols and gets the required data with network calls via interfaces.

The network layer is separated from API through an additional layer called `APIRoute` which will hide API implementation details from network layer.

I ruled out MVC due to it polluting the view layer and making it difficult to just test the business logic due to intermixing with view. I also thought about VIPER architecture, but it seemed an overkill for feature this small given the boilerplate code it tends to add. Finally I decided to use MVVM as a middle ground between these two possible alternatives 

## How to run the app?
App can be run simply by opening "AdyenVenuesList.xcodeproj" file and pressing CMD + R to run it

## Tests

I have written unit tests to test the view model layer and other parts of the app which involves business logic or the data transformation. Tests are written with the mindset to only test the logic layer leaving view layer aside. Unfortunately, I couldn't write unit tests to cover every area in the app, but given more time, I can write it to cover rest of the view model and network layer too.
 
I didn't add any UI tests in the interest of time, but can be added as a follow-up. My idea around UI tests is we can write UI tests (Including snapshot tests) for individual components and end-to-end tests to verify the flow making sure screens load as expected.

## Device support
 This app is currently supported only on iPhone. The only supported orientation is iPhone portrait

## Usage of 3rd party library
The app is completely built using native iOS APIs. No third-party libraries are used

## Deployment Target

App needs minimum version of iOS 14 for the deployment

## Xcode version

App was compiled and run on Xcode version 13.4.1

## API used

I am using official Foursquare API from [this resource](https://developer.foursquare.com/docs/places-api-overview) to get the venues details. 

## Future enhancements

The project can be extended in several ways in the future

1. Add support to select and go to details page by selecting individual venue from the home page
2. Searching for locations
3. Show locations on the map
5. Add UI tests to verify UI integrity

## Swift version used

Swift 5.0


