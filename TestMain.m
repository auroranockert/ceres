//
//  TestMain.m
//  This file is part of Ceres.
//
//  Ceres is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Ceres is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Ceres.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Jens Nockert on 12/8/08.
//

#import "TestMain.h"

int main(int argc, char *argv[])
{
  objc_startCollectorThread();
  
  Ceres * ceres = [Ceres instance];
  
  Data * data = [[Data alloc] init];
  
  [Clone load];
  [Skill load];
    
  NSArray * chars = [Character find];
  
  for(Character * c in chars)
  {
    [c invalidate];
    [c update];
    
    NSLog(@"< %@ (%d) >", [c name], [c identifier]);
    
    NSLog(@"%@ %@ %@", [c race], [c gender], [c bloodline]);
    NSLog(@"Member of > %@ (%d)", [[c corporation] name], [[c corporation] identifier]);
    
    NSLog(@"Clone > %@ (%d SP)", [[c clone] name], [[c clone] skillpoints]);
    
    NSLog(@"Balance > %lf", [c balance]);
    
    NSLog(@"Attributes: \n%@", [c baseAttributes]);
    
    SkillTraining * st = [c skillTraining];
    if ([st training])
    {
      NSLog(@"Training %@ to level %d (%d / %d) and is finished by %@", [[st skill] name], [st level], [st startSkillpoints], [st endSkillpoints], [st endTime]);
    }
    else
    {
      NSLog(@"Not training");
    }
    
    
    NSLog(@" --- ");
  }
  
  return 0;
}
