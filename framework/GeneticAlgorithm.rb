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

class GeneticAlgorithm
  attr_accessor :generation, :population, :best_fitness
  def initialize(problem_instance, population_size, entity_class, max_generations = 100, crossover_rate=0.7, mutation_rate=0.01)
    @population_size = population_size
    @entity_class = entity_class
    @max_generations = max_generations
    @problem_instance = problem_instance
    @crossover_rate, @mutation_rate = crossover_rate, mutation_rate
  end
  
  def selectMember(population, preserve=true)
    total_fitness = population.inject(0) {|sum, member| sum + member.fitness}

    slice = rand(total_fitness)
    partialFitness = 0
    
    selected = population[population.size-1]
    
    for member in population
      partialFitness += member.fitness
      if (partialFitness >= slice)
        selected = member
        break
      end
    end    
    
    if not preserve
      population.delete(selected)
    end
    
    return selected
  end
  
  
  def scoreMember(member, problem_instance)
    return 1
  end
 
  def isSolution?(member, problem_instance)
    return false
  end
  
  def prepare_population(population)    
  end
  
  def run()
    @generation = 0
    @population = []
    if (@population_size % 2 != 0)
      @population_size += 1
    end
    
    for i in 1..@population_size do
      member = @entity_class.new()
      member.fitness = scoreMember(member, @problem_instance)      
      @population.push(member)
    end
    
    found = false
    
    @best_fitness = find_best_fitness(@population)
     
    print "generation... 0"
    
    while not found and (@generation <= @max_generations) do
      
      prepare_population(@population)
      @generation+=1
      newPopulation = []

      for i in 1..@population_size/2 do
        member1 = selectMember(@population)
        member2 = selectMember(@population)
        
        member1 = member1.clone()
        member2 = member2.clone()
        
        member1.chromosome.crossOver(member2.chromosome, @crossover_rate)
        member1.chromosome.mutate(@mutation_rate)
        member2.chromosome.mutate(@mutation_rate)
        
        member1.fitness = scoreMember(member1, @problem_instance)
        member2.fitness = scoreMember(member2, @problem_instance)      
        
        newPopulation.push(member1)
        newPopulation.push(member2)
        
        if (member1.isValid? && isSolution?(member1, @problem_instance))
          @best_fitness = member1
          found = true
          break
        end
        
        if (member2.isValid? && isSolution?(member2, @problem_instance))
          @best_fitness = member2
          found = true
          break
        end
      end
      
      @population = newPopulation
      
      new_best_fitness = find_best_fitness(@population)
      if @best_fitness.fitness < new_best_fitness.fitness
        @best_fitness = new_best_fitness
      end
      
      print "," + @generation.to_s()
    end
    
    
    print " "
    
    return @best_fitness
  end
  
  def find_best_fitness(population)
    max_member = population.at(0)
    population.each do |member|
      if (max_member.fitness < member.fitness)
        max_member = member
      end
    end
    return max_member
  end
  
  def find_worst_fitness(population, upper_bound, lower_bound=0)
    min_member = population.at(0).clone()
    min_member.fitness = upper_bound
    population.each do |member|
      if (member.fitness > lower_bound and min_member.fitness > member.fitness)
        min_member = member
      end
    end
    return min_member
  end
end