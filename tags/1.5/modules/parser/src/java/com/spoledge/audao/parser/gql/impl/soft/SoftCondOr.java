/*
 * Copyright 2010 Spolecne s.r.o. (www.spoledge.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.spoledge.audao.parser.gql.impl.soft;

import com.google.appengine.api.datastore.Entity;


public class SoftCondOr implements SoftCondition {
    private SoftCondition sc1;
    private SoftCondition sc2;


    public SoftCondOr( SoftCondition sc1, SoftCondition sc2 ) {
        this.sc1 = sc1;
        this.sc2 = sc2;
    }


    public boolean getConditionValue( Object[] args, Entity ent ) {
        return sc1.getConditionValue( args, ent ) || sc2.getConditionValue( args, ent );
    }

}
