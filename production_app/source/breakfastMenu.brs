Function CreateBreakfastMenu() as integer
    screen = CreateObject("roPosterScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    
    screen.SetBreadcrumbText("Breakfast", "Full Menu")

    screen.SetContentList(GetBreakfastMenuOptions())
    screen.SetFocusedListItem(4)
    screen.show()
    
    while (true)
        msg = wait(0, port)
        if type(msg) = "roPosterScreenEvent"
            if (msg.isScreenClosed())
                return -1
            else if (msg.isListItemSelected())
                ShowBreakfastItemDetails( msg.GetIndex() )
            endif
        endif
        
    end while
End Function

Function getVideos(id)
   
    url="http://hs3.tv/api/list_games_by_client.php?id="+id
    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
    data2 = "{" + Chr(34) + "Videos" + Chr(34) + ":" + data + "}" 
    
   
    Return data2
End Function

Function CreateSchoolMenu(schoolname, schoolid) as integer

    screen = CreateObject("roPosterScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.SetListStyle("arced-16x9")
    
    screen.SetBreadcrumbText(schoolname, "Full Menu")

    'need to set the 43 to variable passed from previos screen
    screen.SetContentList(GetBreakfastMenuOptions(schoolid))
    screen.SetFocusedListItem(4)
    screen.show()
    
    while (true)
        msg = wait(0, port)
        if type(msg) = "roPosterScreenEvent"
            if (msg.isScreenClosed())
                return -1
            else if (msg.isListItemSelected())
                ShowBreakfastItemDetails( msg.GetIndex() )
            endif
        endif
        
    end while
End Function

Function GetBreakfastMenuOptions(id) as object
    'make integer a string'
    'id2 = 43
    id= id.ToStr()

    'get list of school videos as JSON'
    data = getVideos(id)

    'parse JSON'
    json = ParseJSON(data)

    'declare empty array for video list'
    m.options = []

    'use foreach to populate array
    for each video in json.Videos

        add = { 
            
            ShortDescriptionLine1: video.asset_title
            Price: "$0.99"
            Calories: "350"
            SDPosterURL: "http://video.wtlw.com/p/101/sp/10100/thumbnail/entry_id/"+video.kt_entry_id+"/width/285/height/145"
            HDPosterURL: "http://video.wtlw.com/p/101/sp/10100/thumbnail/entry_id/"+video.kt_entry_id+"/width/385/height/218"
            }
            
    m.options.push(add)
    
    end for
      
    return m.options
End Function

Function ShowBreakfastItemDetails(index as integer) as integer
    print "Selected Index: " + Stri(index)
    detailsScreen = CreateObject("roSpringboardScreen")
    port = CreateObject("roMessagePort")
    detailsScreen.SetMessagePort(port)
    detailsScreen.SetDescriptionStyle("generic")
    detailsScreen.SetBreadcrumbText("Breakfast", m.options[index].ShortDescriptionLine1)
    detailsScreen.SetStaticRatingEnabled(false)
    
    details = {
        HDPosterUrl: m.options[index].HDPosterURL
        SDPosterUrl: m.options[index].SDPosterURL
        Description: m.options[index].ShortDescriptionLine1
        LabelAttrs: ["Price:", "Calories per Serving:"]
        LabelVals: [m.options[index].Price, m.options[index].Calories]
    }
    detailsScreen.SetContent(details)
    detailsScreen.AddButton(1, "Place Order")
    detailsScreen.AddButton(2, "Report to FDA")
    detailsScreen.show()
    
    while (true)
        msg = wait(0, port)
        if type(msg) = "roSpringboardScreenEvent"
            if (msg.isScreenClosed())
                return -1
            else if (msg.isButtonPressed())
                DetailsScreenButtonClicked( msg.GetIndex() )
            endif
        endif
    end while
End Function

Function DetailsScreenButtonClicked(index as integer) as void
    dialog = CreateObject("roOneLineDialog")
    if (index = 1)
        dialog.SetTitle("Placing Order")
    else if (index = 2)
        dialog.SetTitle("Reporting Food to FDA")
    endif
    dialog.ShowBusyAnimation()
    dialog.show()
    
    Sleep(4000)
End Function