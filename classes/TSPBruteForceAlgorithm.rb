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

class Result
  attr_accessor :accumulated_weight, :path
  def initialize(path, accumulated_weight)
    @path = path
    @accumulated_weight = accumulated_weight
  end
  
  def to_s()
    output = "--Path: " + @path.to_s() + "\n"
    output += "--Accumulated Weight: " + @accumulated_weight.to_s() + "\n"
    return output
  end
end

class TSPBruteForceAlgorithm
  attr_accessor :results, :best_result
  def run(graph)
    
    permutations = graph.vertices.permutation().to_a
    @results = []
    
    permutations.each do |permutation|
      path = permutation + [permutation[0]]
      weight = total_weight_if_valid(path, graph)
      if weight
        @results.push(Result.new(path, weight))
      end      
    end
    
    @best_result = find_best_result(@results)
    return @best_result
  end
  
  def find_best_result(results)
    best = results.at(0)
    results.each do |result|
      if (best.accumulated_weight > result.accumulated_weight)
        best = result
      end
    end
    return best
  end
  
  def total_weight_if_valid(path, graph)
    previous = nil
    total = 0
    path.each do |v|
      if previous
        if not graph.has_edge?(previous, v)
          return false
        end
        total += graph.get_weight(previous, v)
      end
      previous = v
    end
    return total
  end
  
  def is_valid_path(path, graph)    
    previous = nil
    path.each do |v|
      if previous and not graph.has_edge?(previous, v)
        return false
      end
      previous = v
    end
    return true
  end
  
  def total_weight(path, graph)
    total = 0
    previous = nil
    path.each do |v|
      if previous
        total += graph.get_weight(previous, v)
      end
      previous = v
    end
    return total
  end
end