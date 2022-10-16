#ifndef BRANCH_PREDICTOR_H
#define BRANCH_PREDICTOR_H

#include <sstream> // std::ostringstream
#include <cmath>   // pow()
#include <cstring> // memset()!
#include "ras.h"

// Add any includes here....
#include <assert.h>     /* assert */
#include <list>

typedef std::list<ADDRINT>::iterator set_iterator_t;


/**
 * A generic BranchPredictor base class.
 * All predictors can be subclasses with overloaded predict(), update(), getNameAndConfig(), getResults()
 * methods.
 **/
class BranchPredictor
{
public:
    BranchPredictor() : correct_predictions(0), incorrect_predictions(0) {};
    ~BranchPredictor() {};

    virtual bool predict(ADDRINT ip, ADDRINT target) = 0;  // target is needed only for some static predictors
    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target, bool isCall=false, bool isRet=false) = 0;
    virtual std::string getNameAndConfig() = 0;
    virtual std::string getResults() = 0;


    void resetCounters() { correct_predictions = incorrect_predictions = 0; };

protected:
    void updateCounters(bool predicted, bool actual) {
        if (predicted == actual)
            correct_predictions++;
        else
            incorrect_predictions++;
    };

    UINT64 correct_predictions;
    UINT64 incorrect_predictions;
};

// ------------------------------------------------------
// NbitPredictor - a generalization of 1,2 bit saturating counters
// ------------------------------------------------------
class NbitPredictor : public BranchPredictor
{
public:
    NbitPredictor(unsigned index_bits_, unsigned cntr_bits_)
        : BranchPredictor(), index_bits(index_bits_), cntr_bits(cntr_bits_) {
        table_entries = 1 << index_bits;
        TABLE = new unsigned int[table_entries];
        memset(TABLE, 0, table_entries * sizeof(*TABLE));
        
        COUNTER_MAX = (1 << cntr_bits) - 1;
        resetCounters();
    };
    ~NbitPredictor() { delete TABLE; };

    virtual bool predict(ADDRINT ip, ADDRINT target) {
        unsigned int ip_table_index = ip % table_entries;
        unsigned long long ip_table_value = TABLE[ip_table_index];
        unsigned long long prediction = ip_table_value >> (cntr_bits - 1);   // get the msb of the counter
        return (prediction != 0);
    };

    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target, bool isCall=false, bool isRet=false) {
        unsigned int ip_table_index = ip % table_entries;
        if (actual) {
            if (TABLE[ip_table_index] < COUNTER_MAX)
                TABLE[ip_table_index]++;
        } else {
            if (TABLE[ip_table_index] > 0)
                TABLE[ip_table_index]--;
        }
        
        updateCounters(predicted, actual);
    };

    virtual std::string getNameAndConfig() {
        std::ostringstream stream;
        stream << "Nbit-" << pow(2.0,double(index_bits)) / 1024.0 << "K-" << cntr_bits;
        return stream.str();
    }

    virtual std::string getResults() {
        std::ostringstream stream;
        stream << "Correct: " << correct_predictions << " Incorrect: "<< incorrect_predictions;
        return stream.str();
    }

private:
    unsigned int index_bits, cntr_bits;
    unsigned int COUNTER_MAX;
    
    unsigned int *TABLE;
    unsigned int table_entries;
};

// Fill in the BTB implementation ...  Assume LRU replacement and full tags
class BTBPredictor : public BranchPredictor
{
public:
    BTBPredictor(int btb_lines, int btb_assoc, int ras_entries_)
        : table_lines(btb_lines), table_assoc(btb_assoc), ras_entries(ras_entries_)
    {
        ras = new RAS(ras_entries_);   // get a RAS
        int num_sets = btb_lines/btb_assoc;
        assert((num_sets & (num_sets-1)) == 0);  // number of sets must be power of 2
        TABLE = new std::list<ADDRINT>[num_sets];   // An array of lists.
        resetCounters();
        /* Write your code here */
    }

    ~BTBPredictor() {
        delete ras;
        delete TABLE;
        /* Write your code here */
    }

    virtual bool predict(ADDRINT ip , ADDRINT target) {
        /* Write your code here */
        return false;
    }
    
    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target, bool isCall=false, bool isRet=false) {
        /* Write your code here */
        //for(int i = 0; i < TABLE.size(); i++){
        //    int index = TABLE[i]%btb_lines;
        //    if (actual) {
         //       if (TABLE[index] == ras[i])
         //           TABLE[index]++;
          /*  } else {
                if (TABLE[index] > 0)
                    TABLE[index]--;
            }
            */
            updateCounters(predicted, actual);
        }    

    virtual std::string getNameAndConfig() { 
        std::ostringstream stream;
        stream << "BTB-" << table_lines << "-" << table_assoc << "-" << ras_entries;
        return stream.str();
    }
   
    virtual std::string getResults() {
        std::ostringstream stream;
        stream << "Correct: " << correct_predictions << " Incorrect: "<< incorrect_predictions;
        /* Write your code here */
        return stream.str();
    }
 
private:
    int table_lines, table_assoc;
    int num_sets;
    int ras_entries;
    RAS *ras;   // the RAS stack
    std::list<ADDRINT> *TABLE;   // An array of lists.
    /* Write your code here */
};

//////////////////////////////////////////////////////////////////////////////////////////////

class NotTakenPredictor : public BranchPredictor
{
public:
   NotTakenPredictor()
      : BranchPredictor() { };

   ~NotTakenPredictor() { };

   virtual bool predict(ADDRINT ip, ADDRINT target){
        unsigned long long prediction = 0;
        return (prediction != 0);
   };

   virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target, bool isCall=false, bool isRet=false)
   {
        updateCounters(predicted, actual);
   };

    virtual std::string getNameAndConfig() 
    {
        std::ostringstream stream;
        stream << "NonT"  ;
        return stream.str();
    }

    virtual std::string getResults() 
    {
        std::ostringstream stream;
        stream << "Correct: " << correct_predictions << " Incorrect: "<< incorrect_predictions;
        return stream.str();
    }


};

/////////////////////////////////////////////////////////////////////////////////////////
class BTFNT_BranchPredictor : public BranchPredictor
{
public:
    BTFNT_BranchPredictor(): BranchPredictor() { };
    ~BTFNT_BranchPredictor() { };

    virtual bool predict(ADDRINT ip, ADDRINT target)
    {
        if (target < ip) {
            return 1;
        } else {
            return 0;
        }
    };

    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target, bool isCall=false, bool isRet=false)
    {
        updateCounters(predicted, actual);
    };

    virtual std::string getNameAndConfig() 
    {
        std::ostringstream stream;
        stream << "BTFNT" ;
        return stream.str();
    }

    virtual std::string getResults() 
    {
        std::ostringstream stream;
        stream << "Correct: " << correct_predictions << " Incorrect: "<< incorrect_predictions;
        return stream.str();
    }

};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Gshare : public BranchPredictor
{
public:
    Gshare(unsigned int index_bits_, unsigned int bhr_bits_, unsigned int length_)
    : BranchPredictor(), index_bits(index_bits_) , bhr_bits(bhr_bits_) , length(length_)
    {
        table_entries = 1 << index_bits;
        table_columns = 1 << bhr_bits;
        TABLE = new unsigned long long[table_entries*table_columns];
        memset(TABLE, 0, table_entries * table_columns * sizeof(*TABLE));
        bhr=0;
        COUNTER_MAX=(1 << length) - 1;
    };
    ~Gshare()
    {
        delete TABLE;
    };

    virtual bool predict(ADDRINT ip, ADDRINT target)
    {
    unsigned int index = ip % table_entries;   // IP MOD 13
    unsigned long long value = TABLE[((index*table_columns) ^ bhr)]; // BHR XOR (IP MOD 13)  
    unsigned long long prediction = value >> (length-1); //RIGHT SHIFT TO GET THE MOST SIGNIFICANT BIT
    return (prediction != 0);
   };

    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target, bool isCall=false, bool isRet=false)
    {
        unsigned int index = ip % table_entries;
        unsigned long long value = TABLE[((index*table_columns) ^ bhr)];

        if (actual){
            if (value < COUNTER_MAX){
                TABLE[((index*table_columns) ^ bhr)]++;
            }
        } else {
        if (value > 0){
            TABLE[((index*table_columns) ^ bhr)]--;
        }
    }

    bhr = bhr << 1;

    if (actual) {
        bhr++;
    }
        bhr = bhr % (1 << bhr_bits);
        updateCounters(predicted, actual);
    };   

    virtual std::string getNameAndConfig() {
        std::ostringstream stream;
        stream << "Gshare-"<< index_bits << "-" << bhr_bits << "-" << length << "K";
        return stream.str();
    }

    virtual std::string getResults() {
        std::ostringstream stream;
        stream << "Correct: " << correct_predictions << " Incorrect: "<< incorrect_predictions;
        return stream.str();
    }

private:
   unsigned int index_bits, bhr_bits, length, bhr;
   unsigned int COUNTER_MAX;

   unsigned long long *TABLE;
   unsigned int table_entries, table_columns;
};
#endif
