# Rails-ERD-D3

Gem is under active development.

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

- Add message after creating
- Sort nodes by label
- Check all associations
    - belongs_to
    - has_one
    - has_many
    - has_many :through
    - has_one :through
    - has_and_belongs_to_many

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RomanKrasavtsev/rails-erd-d3.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Author

[Roman Krasavtsev](https://github.com/RomanKrasavtsev), [@romankrasavtsev](https://twitter.com/romankrasavtsev)
