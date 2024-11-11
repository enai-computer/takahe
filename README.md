# Welcome to the ni Mac-Version


## Company wide standards:

- **ALL views are designed to 16:9 aspect ratio. As it's easier to add height then remove.**
- ALL views get designed with a default 1600px x 900px, but must scale to MBPs high resolutions
- min OS version is 14.x

---  

### What is ni?

Talk to Curran

### How does it work?

Talk to Patrick

## Important Notes

### states of the content frame controller view (`viewstate`)

The view of the content frame controller depends on the NiViewElement to be displayed in it. Here is a diagram showcasing the content and the transitions between the different view states a content frame controller can go through, split by the content types it is displaying. At the moment these are three completely split state diagrams, but it is planned that transition across will become possible and simplified.  

```mermaid
stateDiagram
  direction TB
  state group {
    direction TB
    [*] --> expanded
    state min_choice <<choice>>

    expanded --> min_choice:minimize
    min_choice --> minimized:default choice
    min_choice --> collapsed_minimized:previous state was collapsed minimized
    minimized --> collapsed_minimized
    collapsed_minimized --> minimized
    collapsed_minimized --> expanded
    minimized --> expanded
    expanded --> fullscreen
    fullscreen --> expanded
    simpleMinimised --> fullscreen:if the content is a webview
[*]    expanded
    min_choice
    minimized
    collapsed_minimized
    fullscreen
  }
  state simple_frame {
    direction TB
    simpleMinimised --> CFSimpleFrame
    CFSimpleFrame --> simpleMinimised:if the content is not a webview
    [*] --> CFSimpleFrame
[*]    CFSimpleFrame
    simpleMinimised
  }
  state frameless {
    direction TB
    [*] --> CFFrameless
[*]    CFFrameless
  }
  collapsed_minimized:collapsed minimized
  note left of group : websites use the group view
  note right of simple_frame : pdfs and webapps use a simple frame
  note right of frameless : images and notes use a frameless view. Frameless does not have a minimized state.
```

---  

### special UUIDs

"00000000-0000-0000-0000-000000000000" - Empty Space  
"00000000-0000-0000-0000-000000000001" - Welcome Space  
"00000000-0000-0000-0000-000000000002" - Demo Space (available only in Demo mode)  
"00000000-0000-0000-0000-000000000003" - Default User
