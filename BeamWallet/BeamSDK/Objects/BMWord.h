//
// BMWord.h
// BeamWallet
//
// Copyright 2018 Beam Development
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>


@interface BMWord : NSObject

@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,assign) BOOL correct;
@property (nonatomic,strong) NSString * _Nonnull value;

-(id _Nonnull )init:(NSString* _Nonnull)value index:(NSUInteger)index correct:(BOOL)correct;

@end

