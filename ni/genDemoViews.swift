//Created on 18.10.23

import Cocoa


func generateKoreaView(){
    
    let appDelegate = NSApp.delegate as! AppDelegate
    let koreaSpace = appDelegate.switchToNewSpace()
    
    koreaSpace.setSpaceName("Korea Trip")
    
    let mapView = openWebsite("https://www.google.com/maps/@37.5333643,127.0641291,16.49z?entry=ttu", owner: koreaSpace)
    koreaSpace.addNiFrame(mapView)
    mapView.frame.origin.x = 1500
    mapView.frame.origin.y = 400
    mapView.enaiResize(50, -300)
    
    let calView = openWebsite("https://calendar.google.com/calendar/u/0/r", owner: koreaSpace)
    koreaSpace.addNiFrame(calView)
    calView.frame.origin.x = 100
    calView.frame.origin.y = 50
    calView.enaiResize(50, -100)
    
    let airBnB = openWebsite("https://www.airbnb.com/rooms/41354070?check_in=2023-10-20&check_out=2023-10-22&source_impression_id=p3_1697644269_b8t8TOXvGQfeNDKl&previous_page_section_name=1000&federated_search_id=0375fcd6-ccbe-49b5-b540-a2236d1846d8", owner: koreaSpace)
    koreaSpace.addNiFrame(airBnB)
    airBnB.frame.origin.x = 100
    airBnB.frame.origin.y = 800
    airBnB.enaiResize(-50, -300)
}

func generateFigmaView(){
    let appDelegate = NSApp.delegate as! AppDelegate
    let figmaSpace = appDelegate.switchToNewSpace()
    figmaSpace.setSpaceName("Enai Designs")
    
    let figmaWebsite = openWebsite("https://www.figma.com/file/MbmX98L7dz6fLaF2q3i5kg/MVP?type=design&node-id=0-1&mode=design&t=3l7XQAVFFrtWzmQx-0", owner: figmaSpace)
    
    figmaSpace.addNiFrame(figmaWebsite)
    
    
    //3840x2160 --> 3780x2100
    let targetSize = CGSize(width: 3740, height: 2060)
//    let y = targetSize.height - figmaWebsite.frame.height
    let x = targetSize.width - figmaWebsite.frame.width
    figmaWebsite.enaiResize(x, 0)
//    figmaWebsite.frame.origin.x = 0
//    figmaWebsite.frame.origin.y = 0
}
