/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
     /**
      * An inner class to separate reference counting
      *
      * The threads and idle process add reference counts to the inner
      * class. The lifespan of an instance of the inner class lasts
      * until the idle process and thread are finished.
      *
      * The rest of the system adds reference counts to the outer class.
      * The lifespan of an instance of the outer class lasts until clients
      * no longer needs the outer class.
      *
      * If reference counting occured on an instance of the same class, then
      * an alternate mechanism would be requred to force garbage collection.
      */
    public abstract class Series300Worker : InstrumentWorker
    {
    }
}
