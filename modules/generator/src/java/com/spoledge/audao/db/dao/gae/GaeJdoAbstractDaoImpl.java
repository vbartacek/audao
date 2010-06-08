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
package com.spoledge.audao.db.dao.gae;

import javax.jdo.JDOException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.spoledge.audao.db.dao.DaoException;
import com.spoledge.audao.db.dao.DBException;
import com.spoledge.audao.db.dao.RootDaoImpl;


/**
 * This is the parent of all DAO implementation classes.
 * It uses all common generic methods and utilities.
 * The implementation is not thread safe - we assume
 * that the client creates one DAO impl per thread.
 */
public abstract class GaeJdoAbstractDaoImpl<T> extends RootDaoImpl {

    /**
     * The assigned persistence manager.
     */
    protected PersistenceManager pm;


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Creates a new DAO implementation.
     * @throws NullPointerException when the passed PM is null.
     */
    protected GaeJdoAbstractDaoImpl( PersistenceManager pm ) {
        if (pm == null) {
            throw new NullPointerException("The persistence manager is null");
        }

        this.pm = pm;
    }


    ////////////////////////////////////////////////////////////////////////////
    // Protected
    ////////////////////////////////////////////////////////////////////////////

    protected T findOne( String cond, Object... params) {
        Query q = null;
        String sql = cond;

        try {
            debugSql( sql, params );

            q = getQueryCond( cond );
            q.setRange( 0, 1 );
            q.setUnique( true );

            return fetch( q, params );
        }
        catch (JDOException e) {
            errorSql( e, sql, params );

            throw new DBException( e );
        }
        finally {
            if (q != null) q.closeAll();
        }
    }


    protected T[] findMany( String cond, String order, int offset, int count, Object... params) {
        Query q = null;
        String sql = cond;
        int rangeToExcl;

        if (count < 0 || (count == Integer.MAX_VALUE && offset > 0)) {
            rangeToExcl = Integer.MAX_VALUE;
        }
        else rangeToExcl = offset + count;

        try {
            debugSql( sql, params );

            q = getQueryCond( cond );
            q.setRange( offset, rangeToExcl );

            if (order != null && order.length() > 0) q.setOrdering( order );

            return fetchArray( q, params );
        }
        catch (JDOException e) {
            errorSql( e, sql, params );

            throw new DBException( e );
        }
        finally {
            if (q != null) q.closeAll();
        }
    }


    protected int count( String cond, Object... params) {
        Query q = null;
        String sql = cond;

        try {
            debugSql( sql, params );

            q = getQueryCond( cond );
            q.setResult( "count(this)" );
            q.setUnique( true );

            Object ret = execute( q, params );

            return ((Number) ret).intValue();
        }
        catch (JDOException e) {
            errorSql( e, sql, params );

            throw new DBException( e );
        }
        finally {
            if (q != null) q.closeAll();
        }
    }


    protected boolean deleteOne( String cond, Object... params) throws DaoException {
        int ret = deleteMany( cond, params );

        if (ret > 1) {
            String err = "More than one record deleted";
            log.error( err + " for " + sqlLog( cond, params ));

            throw new DaoException( err );
        }

        return ret == 1;
    }


    protected int deleteMany( String cond, Object... params) throws DaoException {
        Query q = null;
        String sql = cond;

        try {
            debugSql( sql, params );

            q = getQueryCond( cond );

            return (int) q.deletePersistentAll( params );
        }
        catch (JDOException e) {
            errorSql( e, sql, params );

            handleException( e );
            return -1;
        }
        finally {
            if (q != null) q.closeAll();
        }
    }


    protected Query getQueryCond( String cond ) {
        Query q = getQuery();

        if ( cond != null && cond.length() > 0 ) q.setFilter( cond );

        return q;
    }


    protected Query getQueryPlain() {
        return pm.newQuery();
    }


    protected abstract Query getQuery();

    protected abstract T fetch( Query q, Object... params );
    protected abstract T[] fetchArray( Query q, Object... params );


    protected void handleException( JDOException e ) throws DaoException {
        throw new DaoException( e );
    }


    protected final Object execute( Query q, Object[] params) {
        if ( params != null && params.length != 0 ) {
            return q.executeWithArray( params );
        }
        else {
            return q.execute();
        }
    }


    protected final java.util.Date date( java.sql.Date val ) {
        return val != null ? new java.util.Date( val.getTime()) : null;
    }


    protected final java.util.Date date( java.sql.Timestamp val ) {
        return val != null ? new java.util.Date( val.getTime()) : null;
    }

}

