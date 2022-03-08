## FOS - Trigger Event(s)

![](https://img.shields.io/badge/Plug--in_Type-Dynamic_Action-orange.svg) ![](https://img.shields.io/badge/APEX-19.2-success.svg) ![](https://img.shields.io/badge/APEX-20.1-success.svg) ![](https://img.shields.io/badge/APEX-20.2-success.svg) ![](https://img.shields.io/badge/APEX-21.1-success.svg) ![](https://img.shields.io/badge/APEX-21.2-success.svg)

Dynamic Action to trigger an event with an optional data object declaratively.
<h4>Free Plug-in under MIT License</h4>
<p>
All FOS plug-ins are released under MIT License, which essentially means it is free for everyone to use, no matter if commercial or private use.
</p>
<h4>Overview</h4>
<p>The <strong>FOS - Trigger Event</strong> dynamic action plug-in is used for controlling the branching logic (if/then/else) within a dynamic action. It gives you/developers the declarative ability to fire custom event(s) which other dynamic actions can listen to, whilst giving you the option to cancel the following actions in the current dynamic action. Hence why we use the term branching.</p>
<h3>Conditional Event Firing</h3>
<p>The plug-in has the added flexibility of allowing you to define a client-side condition as to whether you fire the event. It is somewhat similar to our "FOS - Client-side Condition" dynamic action, but provides more focus on branching of logic through the firing of events.</p>
<h3>Multiple Events</h3>
<p>You can also fire multiple events by comma separating them, as well as defining the "data" object that is passed into the event in case you need to transfer extra information. Why wouldn't I just use multiple actions instead? Our goal is to focus on efficiency and reduce the overall number of actions that developers create. Since we're firing an event already, we thought we should give you the ability to fire multiple events.</p>

## License

MIT

