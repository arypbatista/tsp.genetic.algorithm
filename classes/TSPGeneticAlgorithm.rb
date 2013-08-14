#
# Copyright (C) 2013 Ary Pablo Batista <arypbatista@gmail.com>, 
#                    Rodrigo Oliveri <rodrigooliveri10@gmail.com>
#
# This file is part of TSPGeneticAlgorithm (hereinafter, this program).
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

require "./framework/GeneticAlgorithm.rb"
require "./classes/Traveller.rb"
require "./support/IntegerUtils.rb"

class TSPGeneticAlgorithm < GeneticAlgorithm
  @@ARRIVED_PRIZE_RATE=0.4
  attr_accessor :minimum_spanning_tree, :worst_fitness
  
  def initialize(graph, population_size, max_generations=100, crossover_rate=0.7, mutation_rate=0.01)
    gen_sizes = Array.new    
    (0..graph.vertices.size).each do |i|
      gen_sizes.push(graph.vertices.size-1)
    end
    Traveller.gen_sizes(gen_sizes)
    super(graph, population_size, Traveller, max_generations, crossover_rate, mutation_rate)
    
    @minimum_spanning_tree = graph.minimum_spanning_tree
    @weight_upper_bound = @minimum_spanning_tree.total_weight * 2
  end
  
  def prepare_population(population)    
    member = find_worst_fitness(population, 1510, 1400)
    if @worst_member
      if @worst_member.fitness > member.fitness
        @worst_fitness = member  
      end
    else
      @worst_fitness = member
    end
  end
  
  def scoreMember(member, graph)
    member.travel(graph)
    return scoreForValues(Set.new(member.visited_nodes), member.arrived, member.accumulated_weight)
  end
  
  def scoreForValues(visited_nodes, arrived, accWeight)       
    visited_score = visited_nodes.size.to_f() / @problem_instance.vertices.size.to_f() * 1000
    score = visited_score
    if arrived and visited_nodes.size == @problem_instance.vertices.size then
      # Weights
      score += (@problem_instance.total_weight - accWeight).to_f() / @problem_instance.total_weight.to_f() * 100
      # Arrived priced
      score += (visited_score*@@ARRIVED_PRIZE_RATE).ceil
    end
    return score
  end
  
  def heaviest_edges_weight(graph, count)
    max_weights = []
    count.times do
      max_weights += [-1]
    end
    
    for edge in graph.edges do
      if max_weights[0] < edge[2]
        max_weights[0] = edge[2]
        max_weights.sort!
      end 
    end

    sum = 0
    max_weights.each do
      |w| sum += w
    end
    return sum
  end
  
  def maxScore(graph)
    scoreForValues(graph.vertices, true, @weight_upper_bound)
  end
  
  def isSolution?(member, graph)
    return member.fitness >= maxScore(graph)
  end
end