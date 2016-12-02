[![Gem Version](https://badge.fury.io/rb/rails-erd-d3.svg)](https://badge.fury.io/rb/rails-erd-d3)
[![Code Climate](https://codeclimate.com/github/RomanKrasavtsev/rails-erd-d3/badges/gpa.svg)](https://codeclimate.com/github/RomanKrasavtsev/rails-erd-d3)

# Rails-ERD-D3

Create entity–relationship diagram with D3.js for your Rails application.

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  gem "rails-erd-d3"
end
```

And then execute for creating file erd.html:

    $ rails c
    > RailsErdD3.create

## Todo

- Sort nodes by label
- Check all associations
    - [X] belongs_to
    - [X] has_one
    - [x] has_many
    - has_many :through
    - has_one :through
    - has_and_belongs_to_many
- Hide model
- Show model attributes
- Safe as jpg, png
- Dependent destroy

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RomanKrasavtsev/rails-erd-d3.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Author

[Roman Krasavtsev](https://github.com/RomanKrasavtsev), [@romankrasavtsev](https://twitter.com/romankrasavtsev)
