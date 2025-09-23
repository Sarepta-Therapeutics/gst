# obrien() works for OLS

    Code
      obrien(data = multcomp::mtept, endpoint_vars = c("E1", "E2", "E3", "E4"),
      treatment_vars = "treatment", method = "ols")
    Output
      $statistic
              t 
      -2.137555 
      
      $df
       df 
      109 
      
      $pvalue
      [1] 0.03478787
      
      $alternative
      [1] "two.sided"
      
      $R
                 E1         E2         E3         E4
      E1  1.0000000  0.3826183  0.6374516 -0.6952211
      E2  0.3826183  1.0000000  0.4475470 -0.4259170
      E3  0.6374516  0.4475470  1.0000000 -0.6323512
      E4 -0.6952211 -0.4259170 -0.6323512  1.0000000
      

# obrien() works for GLS method

    Code
      obrien(data = multcomp::mtept, endpoint_vars = c("E1", "E2", "E3", "E4"),
      treatment_vars = "treatment", method = "gls")
    Output
      $statistic
              t 
      -0.395645 
      
      $df
       df 
      109 
      
      $pvalue
      [1] 0.6931402
      
      $alternative
      [1] "two.sided"
      
      $R
                 E1         E2         E3         E4
      E1  1.0000000  0.3826183  0.6374516 -0.6952211
      E2  0.3826183  1.0000000  0.4475470 -0.4259170
      E3  0.6374516  0.4475470  1.0000000 -0.6323512
      E4 -0.6952211 -0.4259170 -0.6323512  1.0000000
      

# obrien() works for Ranksum method

    Code
      obrien(data = multcomp::mtept, endpoint_vars = c("E1", "E2", "E3", "E4"),
      treatment_vars = "treatment", method = "ranksum")
    Output
      $statistic
              t 
      -1.281139 
      
      $df
       df 
      109 
      
      $pvalue
      [1] 0.2028639
      
      $alternative
      [1] "two.sided"
      
      $R
                 E1         E2         E3         E4
      E1  1.0000000  0.3826183  0.6374516 -0.6952211
      E2  0.3826183  1.0000000  0.4475470 -0.4259170
      E3  0.6374516  0.4475470  1.0000000 -0.6323512
      E4 -0.6952211 -0.4259170 -0.6323512  1.0000000
      

