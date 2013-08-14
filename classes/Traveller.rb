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

require "./framework/GeneticEntity.rb"
require "./framework/Chromosome.rb"

class Traveller < GeneticEntity
  def Traveller::gen_sizes (array)
    @@gen_sizes=array   
  end
  
  def get_gen_sizes
    @@gen_sizes
  end
  
  attr_accessor :visited_nodes, :initial_node, :origin_node, :end_node, :arrived, :accumulated_weight,
                :decisions, :decisions_made
 
  def initialize(chromosome=nil)
    super(chromosome)
    @arrived = false
    @decisions_made = []  
  end
  
  def loadAttributes(chromosome)
    gens = chromosome.getGens()
    @initial_node = gens.delete_at(0)
    @decisions = gens
  end
   
  def next_decision(decisions_count)
    decision = @decisions.pop() % decisions_count
    @decisions_made.push(decision)
    return decision
  end
  
  def travel(graph)
      @visited_nodes = []
      @accumulated_weight = 0
      @origin_node = graph.vertices[@initial_node % graph.vertices.size]
      current_node = @origin_node      
      #@end_node = current_node
      @visited_nodes.push(@origin_node)
      end_loop = false
      
      while (not end_loop) do
        if not graph.out_degree(current_node) == 0 
          previous_node = current_node
          current_node = self.chooseAdjacent(graph.adjacent_vertices(current_node))
          if (not current_node == nil) then
            @visited_nodes.push(current_node)
            @accumulated_weight += graph.get_weight(previous_node, current_node)
            @end_node = current_node
          end
          if (current_node == nil) then
            end_loop = true
          end
        else
          end_loop = true
        end
      end
      
     if graph.adjacent_vertices(@end_node).include?(@origin_node)
       @arrived = true
       @accumulated_weight += graph.get_weight(@end_node, @origin_node)
       @end_node = @origin_node
       @visited_nodes.push(@end_node)
     end      
  end
  
  def chooseAdjacent(adjacents)
    elegible_adjacents = adjacents.reject{|e| @visited_nodes.include?(e)}
    return nil if (elegible_adjacents.size == 0)
    return elegible_adjacents.at(next_decision(elegible_adjacents.size))
  end
  
end