# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gingham is a Ruby gem implementing an original 3D grid-based pathfinding algorithm, designed for turn-based tactical games. It handles movement simulation, collision detection, and team-based interactions on a 3D grid.

## Key Commands

### Testing
```bash
# Run all tests
rake spec

# Run specific test file
bundle exec rspec spec/gingham/path_finder_spec.rb

# Run tests with specific example
bundle exec rspec spec/gingham/path_finder_spec.rb -e "finds path"
```

### Development
```bash
# Install dependencies
bundle install

# Interactive console for testing
bin/console

# Build gem locally
gem build gingham.gemspec

# Install gem locally
bundle exec rake install
```

## Architecture Overview

### Core Components

1. **Spatial System** - 3D grid representation
   - `Space` (lib/gingham/space.rb): 3D grid container managing cells
   - `Cell` (lib/gingham/cell.rb): Individual grid units with height and occupancy
   - `Position` (lib/gingham/position.rb): 3D coordinates (x, y, z)

2. **Pathfinding Engine**
   - `PathFinder` (lib/gingham/path_finder.rb): Core A* pathfinding with 3D support, jump power, and turn costs
   - `Waypoint` (lib/gingham/waypoint.rb): Path nodes containing position, direction, and pathfinding metadata
   - `Direction` (lib/gingham/direction.rb): Directional constants (D2, D4, D6, D8 representing numpad directions)

3. **Movement Simulation**
   - `MoveSimulator` (lib/gingham/move_simulator.rb): Handles simultaneous movement of multiple actors
   - `Actor` (lib/gingham/actor.rb): Entities with team_id, move_power, jump_power
   - `MoveStatus` (lib/gingham/move_status.rb): Movement states (DEFAULT, STAY, STOPPED, FINISHED)
   - `TimeLine` (lib/gingham/time_line.rb): Manages temporal movement sequences
   - `MoveFrame` (lib/gingham/move_frame.rb): Single frame in movement timeline

### Key Concepts

- **Team System**: Actors have team_ids affecting collision behavior (same team = pass through, different team = collision)
- **3D Movement**: Handles height differences with jump_power limitations
- **Turn Costs**: Optional directional facing affects movement cost
- **Skill Ranges**: PathFinder can calculate attack/skill ranges from waypoints
- **Movement Margins**: PathFinder supports move_margin for extended range calculations

## Testing Approach

- Uses RSpec with documentation format
- Tests organized by component in spec/ directory
- Coverage reporting with Coveralls
- Travis CI for Ruby 2.2.4 and 2.3.0

## Dependencies

- ActiveSupport ~> 4.2 (runtime)
- RSpec ~> 3.0 (development)
- Bundler ~> 1.11 (development)