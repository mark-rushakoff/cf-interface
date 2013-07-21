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
Exactly one of those arguments will be nil.

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

If there was a deserialization error, error will be an instance of `::CF::Interface::DeserializationError` (which has a `#original` method wrapping the underlying error for why the deserialization failed).

### Extending the gem

#### Adding a message

Under most circumstances, a message should be able to `include Broadcastable` to provide the `#broadcast` method and `extend Receivable` to provide the `.on_receive` method.

Most messages will have the following customized methods:

* `#serialize`: serializes the given object to a string
* `#valid?`: returns true if the object is suitable for serialization
* `.deserialize`: given a string, returns a new instance of the message. Should raise an exception if the deserialization is unsuccessful.
* `.channel`: (An implementation detail of using CF Message Bus.)

#### Testing a new message

I like [spec/component_announcement_message_spec.rb](spec/component_announcement_message_spec.rb) as a good example of full specs for a message.
It covers:

* Capturing the correct NATS channel for compatibility with existing messages and documentation purposes
* Error condition when initializing with extra data
* Validating the message (important for error conditions on serialization)
* Raising an error when deserializing an invalid serialization
* Broadcasting and receiving the message with a mock message bus to test serialization and deserialization together

## TODO

CF Interface currently only covers broadcasting and receiving messages.
The following functionality is still missing:

* Requesting a particular message on a private inbox
* Synchronously requesting a message with timeout or max count
* Strategy to split "polymorphic" messages (e.g. DropletStop) into separate channels while maintaining backwards compatibility (or is BC even needed? Maybe we can allow a breaking change for this?)
* Extend CfMessageBus to not make assumptions about (de)serialization; that responsibility should fall on this layer
