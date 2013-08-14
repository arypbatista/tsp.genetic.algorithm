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

class Integer
  
  def bits_needed
    #Bits needed to represent the total amount of number
    Math.log2(self).ceil
  end
  
  def to_bitsarray (max=self)
    #Generates a bits array of the number with a max lenght in bits
    ("%#{max.bits_needed}d" % self.to_s(2)).split('').map{ |e| e.to_i }
  end
  
  def min(other)
    self < other ? self : other
  end
  
  def max(other)
    self > other ? self : other
  end
end
