# Cf::Interface

This gem is intended to be used as a single point of contact for inter-component communication in Cloud Foundry.

## Overview

### Using the gem

#### Sending a message

Create the instance of the message representing the action you want to take, e.g. `ComponentAnnouncementMessage`.
Then call its `#broadcast` method, passing in an instance of `Cf::Interface::Interface`.

```ruby
message = ::Cf::Interface::ComponentAnnouncementMessage.new(
  component_type: "easter_egg",
  index: my_index,
  host: my_host,
  credentials: credential_hash
)

message.broadcast(interface)
```

If you try to broadcast an invalid message, you will raise an instance of `::Cf::Interface::SerializationError`.

#### Subscribing to a message

Messages have a class method `.on_receive` that takes an interface and a block.
When a valid message is received on that channel, the provided block is called with the instance of that message or the deserialization error as its argument.
Exactly one of those arguments should be nil.

```ruby

::Cf::Interface::ComponentAnnouncementMessage.on_receive do |announcement, error|
  if error
    logger.fatal("Can't recover from parse failure: #{error}")
    abort
  else
    logger.info("Received announcement from #{announcement.component_type}/#{announcement.index}")
  end
end
```

### Extending the gem

#### Adding a message

Under most circumstances, a message should be able to `include Broadcastable` to provide the `#broadcast` method and `extend Receivable` to provide the `.on_receive` method.

Most messages will have the following customized methods:

* `#serialize`: serializes the given object to a string
* `#valid?`: returns true if the object is suitable for serialization
* `.deserialize`: given a string, returns a new instance of the message. Should raise an exception if the deserialization is unsuccessful.
* `.channel`: (An implementation detail of using CF Message Bus.)
