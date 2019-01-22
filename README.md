# efax [![Build Status](https://secure.travis-ci.org/szimek/efax.png)](http://travis-ci.org/szimek/efax)

Ruby library for accessing [eFax Developer service](http://www.efaxdeveloper.com).

You can find eFax Developer API guides at [efaxdeveloper.com](https://secure.efaxdeveloper.com/techDocs/eFaxDeveloper_Universal_Implementation_Kit_v1.0.zip) or on [Scribd](http://www.scribd.com/doc/5382394/eFax-Developer-Universal-User-Guide-Outbound).

## Usage

### Outbound Faxes

First you need to provide your account id and credentials:

```ruby
EFax::Request.account_id = <your account id>
EFax::Request.user       = <your login>
EFax::Request.password   = <your password>
```
Sending an HTML page using eFax service is pretty simple:

```ruby
response = EFax::OutboundRequest.post(recipient_name, company_name, fax_number, subject, content)
```

Sending an PDF page:

```ruby
response = EFax::OutboundRequest.post(recipient_name, company_name, fax_number, subject, content, :pdf)
```

Adding Dispositions:

Dispositions are either a https endpoint or a set of email addresses for eFax to notify upon fax delivery or failure. Examples:

HTTPs endpoint:
```ruby
disposition = {
  method: "POST", # Send final results to URL. Options: [POST, EMAIL, NONE (default)]
  level: "BOTH",  # Send success and error messages. Options: [ERROR | SUCCESS | BOTH | NONE (default)]
  url: "https://test.example.com" # Note: URL has limit of 100 char, and any `&` will be converted to `&amp;`
}
response = EFax::OutboundRequest.post(recipient_name, company_name, fax_number, subject, content, :html, disposition)
```

Email:
```ruby
disposition = {
  method: "EMAIL", # Send final results via email. Options: [POST, EMAIL, NONE (default)]
  level: "BOTH", # Send success and error messages. Options: [ERROR | SUCCESS | BOTH | NONE (default)]
  emails: [
    {
      recipient: "Sample 1", # Optional
      address: "sample1@example.com",
    },
    {
      recipient: "Sample 2", # Optional
      address: "sample2@example.com",
    }
  ]
}
response = EFax::OutboundRequest.post(recipient_name, company_name, fax_number, subject, content, :html, disposition)
```

See `EFax::RequestStatus` class for details on status codes.


Having ID of your request, you can get its current status:

```ruby
response = EFax::OutboundStatus.post(doc_id)
```

The status response has the following attributes:

```ruby
response.status_code
response.message          # "user friendly" status message
```

See `EFax::QueryStatus` class for details on status codes.

### Inbound Faxes

Inbound faxes work by exposing a URL that EFax can post to when it receives a fax on your account. An example end-point in rails might look like this:

```ruby
class InboundFaxesController < AdminController
  def create
    efax = EFax::InboundPostRequest.receive_by_params(params)
    Fax.create(:file => efax.file, :name => efax.name) # etc
    render :text => efax.post_successful_message # This is important to let EFax know you successfully processed the incoming request.
  end
end
```

## Test helpers

You can generate a `EFax::InboundPostRequest` based on optional explicit fields by using a helper method `efax_inbound_post`:

In your tests:

```ruby
require "efax/helpers/inbound_helpers"

describe InboundFax do
  include EFax::Helpers::InboundHelpers

  it "should create a fax from efax data" do
    person = Person.make
    person.save
    efax = efax_inbound_post(:barcode => person.barcode_number)
    fax = InboundFax.create_from_efax!(efax)
    fax.person.should == person
  end
end
```

## Development

## Run tests:
* `docker-compose up --build`
* `bin/run_tests`
