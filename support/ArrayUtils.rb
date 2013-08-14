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

class Array
  
  def swap!(a,b)
    self[a], self[b] = self[b], self[a]
    self
  end
  
  def swapArraysRange (array2, range)
    #Swap the values of 2 arrays in a given range indexes
    arraytot=self+array2
    range.each {
      |i|
      arraytot.swap!(i, i + self.size)
      }
    self.replace(arraytot[0,self.size])
    array2.replace(arraytot.slice(self.size, array2.size))
    self
  end
  
  def bitsarray_toint
    int=0
    for i in (0..(self.size-1))
      int+=(self[i]*(2**(self.size-1-i)))
    end
    return int
  end
  
  def include_subarray?(subarray)
    found = false
    if self.size >= subarray.size
      temp = self + self.slice(0, subarray.size-1)   
      temp.each_index {|i| found = found || (temp.slice(i, subarray.size) == subarray)}
    end
    found
  end
end