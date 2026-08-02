enum 50007 "ASL.EFRIS.LogLevel"
{
    Extensible = true;

    value(0;
    OFF)
    {
    } // nothing
    value(100;
    ERROR)
    {
    } // errors
      /*
        value(200; DEBUG) { } // may be useful for debugging
        value(300; INFO) { }  // information
        */
    value(400;
    TRACE)
    {
    } // detailed information
}
