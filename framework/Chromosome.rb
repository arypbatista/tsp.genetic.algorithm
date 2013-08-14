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

require "./support/ArrayUtils.rb"
require "./support/IntegerUtils.rb"

class Chromosome
  
  attr_accessor :gen_sizes, :chain
  
  # Generate a random gens
  def Chromosome::random(gen_sizes)
    gens = gen_sizes.collect { |max| rand(0..max)}
    Chromosome::create(gens, gen_sizes)
  end
  
  def Chromosome::create(gens, gen_sizes)
    chromosome = Chromosome.new
    chromosome.gen_sizes = gen_sizes
    chromosome.setGens(gens)
    return chromosome
  end
  
  def initialize(bits_chain=[], gen_sizes=[])     
    @chain = bits_chain  
    @gen_sizes = gen_sizes
  end
  
  def clone()
    Chromosome.new(@chain, @gen_sizes)
  end
  
  # Builds bits chain from gens (integer array)
  def setGens(gens)
    @chain = []    
    gen_sizes.each_index { |i| @chain.concat(gens[i].to_bitsarray(gen_sizes[i] + 1)) }
  end
  
  # Gets the integer value of one gen
  def getGens ()
    init=0
    gens_array = []
    for max in @gen_sizes      
      gens_array.push(self.chain[init,(max+1).bits_needed].bitsarray_toint)
      init += (max+1).bits_needed
    end
    return gens_array
  end
  
  def crossOver (chromosome, crossover_rate)
    if (rand() <= crossover_rate)
      crossover_start = rand(chain.size)    
      self.chain.swapArraysRange(chromosome.chain,(crossover_start..self.chain.size-1))
    end
  end
  
  def mutate(mutation_rate)
    # Probabilistic swap of 0 and 1
    @chain.map! {|bit| (rand() <= mutation_rate) ? (bit-1).abs : bit }
  end
  
  def to_s()
    return @chain.join
  end
end