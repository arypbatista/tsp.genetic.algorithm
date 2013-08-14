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

class Traveller
  def to_s()
    output = "Chromosome: " + @chromosome.to_s() + "\n"
    output += "Member attributes:\n"
    output += "--Initial node: " + @initial_node.to_s() + "\n"
    output += "--Decisions sequence: " + @decisions_made.to_s() + "\n"
    output += "Member solution:\n"
    output += "--Arrived: " + @arrived.to_s() + "\n"
    output += "--Path: " + @visited_nodes.to_s() + "\n"
    output += "--Accumulated Weight: " + @accumulated_weight.to_s() + "\n"
    output += "Member score: " + @fitness.to_s() + "\n"
    return output
  end
end

class TSPGeneticAlgorithm
  def to_s()
    output = ""
    output += "Minimum Spanning Tree's Total Weight: " + @minimum_spanning_tree.total_weight.to_s() + "\n"
    output += "Upper bound for weight: " + @weight_upper_bound.to_s() + "\n"
    output += "Vertex count: " + @problem_instance.vertices.size.to_s() + "\n"
    output += "Edge count: " + @problem_instance.edges.size.to_s() + "\n"
    output += "Population size was " + @population_size.to_s() + "\n"
    output += "Solution reached in " + @generation.to_s() + " of " + (@max_generations + 1).to_s() + " generations.\n"
    output += "Solution minimum score: " + maxScore(@problem_instance).to_s() + "\n"
    output += "-----------------------------------\n"
    output += "Best fitness member was:\n"
    output += @best_fitness.to_s()
    output += "-----------------------------------\n"
    output += "Worst fitness member was:\n"
    output += @worst_fitness.to_s()
    return output
  end
end