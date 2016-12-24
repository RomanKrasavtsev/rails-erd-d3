[![Build Status](https://travis-ci.org/RomanKrasavtsev/rails-erd-d3.svg?branch=master)](https://travis-ci.org/RomanKrasavtsev/rails-erd-d3)
[![Gem Version](https://badge.fury.io/rb/rails-erd-d3.svg)](https://badge.fury.io/rb/rails-erd-d3)
[![Code Climate](https://codeclimate.com/github/RomanKrasavtsev/rails-erd-d3/badges/gpa.svg)](https://codeclimate.com/github/RomanKrasavtsev/rails-erd-d3)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/RomanKrasavtsev/rails-erd-d3/master/LICENSE.txt)
![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/rails-erd-d3?type=total)

# Rails-ERD-D3

Create entity–relationship diagram with D3.js for your Rails application.

## Demo
[https://romankrasavtsev.github.io/rails-erd-d3/](https://romankrasavtsev.github.io/rails-erd-d3/)

## Features
Rails-ERD-D3 contains the following functionality:

###View models and their associations
![Models](https://github.com/RomanKrasavtsev/rails-erd-d3/raw/master/images/models.png)

###Preferences where you could hide any models
![Preferences](https://github.com/RomanKrasavtsev/rails-erd-d3/raw/master/images/preferences.png)

###View associations
![Associations](https://github.com/RomanKrasavtsev/rails-erd-d3/raw/master/images/associations.png)

###View table structure
![Table structure](https://github.com/RomanKrasavtsev/rails-erd-d3/raw/master/images/table_structure.png)

## Installation

Add these lines to your application's Gemfile:

```ruby
group :development do
  gem "rails-erd-d3"
end
```

Install gem:
```shall
$ bundle install
```

And then execute for creating file erd.html:
```shall
$ bundle exec rails-erd-d3
```

## Todo
- Add zoom
  ```
// https://jsfiddle.net/owen_rodda/55zk55ut/16/
var svg = d3.select('#erd')
  .call(d3.zoom().on("zoom", zoomed))

function zoomed() {
  svg.attr("transform",
    "translate("
    + d3.event.transform.x + ","
    + d3.event.transform.y + ")"
    + " scale(" + d3.event.transform.k
    + ")"
  );
  ```
- Add arrows
```
svg.append("defs").append("marker")
  .attr("id", "arrow")
  .attr("viewBox", "0 -5 10 10")
  .attr("refX", 32)
  .attr("refY", 0)
  .attr("markerWidth", 7)
  .attr("markerHeight", 7)
  .attr("orient", "auto")
.append("svg:path")
  .attr("d", "M0,-5L10,0L0,5");

var link = svg.append('g')
  .attr("marker-end", "url(#arrow)");
```
- Add
```
var link = svg.append('g')
  .attr('stroke-width', 2)
```
- Add
```
node.append('circle')
  .attr('stroke', 'white')
  .attr('stroke-width', 3)
```
- Freeze
  - On
    ```
    node.call(d3.drag()
          .on('start', dragstarted)
          .on('drag', dragged)
          .on('end', dragended));
    ```
  - Off
    ```
    node.call(d3.drag().on('drag', null))
    ```  
- Add link to another model in model window
- Add tests
  - ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
- Sort nodes by label
- Check associations
    - [X] belongs_to
    - [X] has_one
    - [x] has_many
    - has_many :through
    - has_one :through
    - has_and_belongs_to_many
    - Polymorphic associations
- Safe as jpg, png
- Dependent destroy

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RomanKrasavtsev/rails-erd-d3.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Author

[Roman Krasavtsev](https://github.com/RomanKrasavtsev), [@romankrasavtsev](https://twitter.com/romankrasavtsev)
