/*
 * Random.hpp
 * 
 * Copyright 2025 x64x2 <x64x2@mango>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */


#ifndef RANDOM_HPP
#define RANDOM_HPP

/**
 * Provides a source of randomness using the mersenne twister algorithm.
 */
class Random
{
public:
	/**
	 * Create a new random number generator.
	 */
	Random();

	/**
	 * Get the next value as a signed integer.
	 */
	int nextInt();

	/**
	 * Get the next value as a signed integer in the range [0, range).
	 */
	int nextInt( int range );

	/**
	 * Get the next value as a signed integer in the range [min, max).
	 */
	int nextInt( int min, int max );

	/**
	 * Get the next value as a real in the domain [0, 1].
	 */
	double nextReal();

	/**
	 * Get the next value as a real in the domain [0, 1).
	 */
	double nextRealOpen();

	/**
	 * Get the next value as an unsigned integer.
	 */
	unsigned int nextUnsigned();

	/**
	 * Seed the random number generator with a value.
	 */
	void seed( unsigned int value );

	/**
	 * Seed the random number generator using the current time.
	 */
	void seedTime();

private:
	static const unsigned int N = 624; /**< State machine size. */
	static const unsigned int M = 397;
	static const unsigned int MATRIX_A = 0x9908b0df;
	static const unsigned int UPPER_MASK = 0x80000000;
	static const unsigned int LOWER_MASK = 0x7fffffff;

	unsigned int mt[N];    /**< The state machine. */
	int mti;               /**< Some other state variable. */
	unsigned int mag01[2]; /**< Yet another state variable. */

	// Original Mersenne Twister functions:
	void init_genrand(unsigned int s);
	void init_by_array(unsigned int init_key[], int key_length);
	unsigned int genrand_int32(void);
	int genrand_int31(void);
	double genrand_real1(void);
	double genrand_real2(void);
	double genrand_real3(void);
	double genrand_res53(void);
};
