//
//  TestMain.m
//  This file is part of CeresIO.
//
//  CeresIO is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  CeresIO is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with CeresIO.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Jens Nockert on 3/3/09.
//

#import "TestMain.h"

int main(int argc, char *argv[])
{
  objc_startCollectorThread();
  
  IOHttpRequestChannel * channel = [[IOHttpRequestChannel alloc] initWithUrl: [NSURL URLWithString: @"http://Ceres.doesntexist.org/ceres.xml"]];
  
  IOCompositeFuture * compositeFuture = [[IOCompositeFuture alloc] initWithFutures: [NSSet setWithObjects: [channel receive], [channel receive], [channel receive], nil]];
  
  [compositeFuture join];
  
  NSLog(@"Result: %@", [compositeFuture result]);
  
  return 0;
}
